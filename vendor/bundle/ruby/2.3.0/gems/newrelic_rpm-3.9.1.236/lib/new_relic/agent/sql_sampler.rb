# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

require 'zlib'
require 'base64'
require 'digest/md5'

require 'new_relic/agent'
require 'new_relic/control'

module NewRelic
  module Agent
    # This class contains the logic of recording slow SQL traces, which may
    # represent multiple aggregated SQL queries.
    #
    # A slow SQL trace consists of a collection of SQL instrumented SQL queries
    # that all normalize to the same text. For example, the following two
    # queries would be aggregated together into a single slow SQL trace:
    #
    #   SELECT * FROM table WHERE id=42
    #   SELECT * FROM table WHERE id=1234
    #
    # Each slow SQL trace keeps track of the number of times the same normalized
    # query was seen, the min, max, and total time spent executing those
    # queries, and an example backtrace from one of the aggregated queries.
    #
    # @api public
    class SqlSampler

      # Module defining methods stubbed out when the agent is disabled
      module Shim
        def on_start_transaction(*args); end
        def on_finishing_transaction(*args); end
      end

      attr_reader :disabled

      # this is for unit tests only
      attr_reader :sql_traces

      def initialize
        @sql_traces = {}

        # This lock is used to synchronize access to @sql_traces
        # and related variables. It can become necessary on JRuby or
        # any 'honest-to-god'-multithreaded system
        @samples_lock = Mutex.new
      end

      def enabled?
        Agent.config[:'slow_sql.enabled'] &&
          Agent.config[:'transaction_tracer.enabled'] &&
          NewRelic::Agent::Database.should_record_sql?(:slow_sql)
      end

      def on_start_transaction(state, start_time, uri=nil)
        return unless enabled?

        state.sql_sampler_transaction_data = TransactionSqlData.new

        if state.transaction_sample_builder
          guid = state.transaction_sample_builder.sample.guid
        end

        if Agent.config[:'slow_sql.enabled'] && state.sql_sampler_transaction_data
          state.sql_sampler_transaction_data.set_transaction_info(uri, guid)
        end
      end

      def tl_transaction_data # only used for testing
        TransactionState.tl_get.sql_sampler_transaction_data
      end

      # This is called when we are done with the transaction.
      def on_finishing_transaction(state, name, time=Time.now)
        return unless enabled?

        data = state.sql_sampler_transaction_data
        return unless data

        data.set_transaction_name(name)
        if data.sql_data.size > 0
          @samples_lock.synchronize do
            ::NewRelic::Agent.logger.debug "Harvesting #{data.sql_data.size} slow transaction sql statement(s)"
            harvest_slow_sql data
          end
        end
      end

      # this should always be called under the @samples_lock
      def harvest_slow_sql(transaction_sql_data)
        transaction_sql_data.sql_data.each do |sql_item|
          normalized_sql = sql_item.normalize
          sql_trace = @sql_traces[normalized_sql]
          if sql_trace
            sql_trace.aggregate(sql_item, transaction_sql_data.path,
                                transaction_sql_data.uri)
          else
            @sql_traces[normalized_sql] = SqlTrace.new(normalized_sql,
                sql_item, transaction_sql_data.path, transaction_sql_data.uri)
          end
        end
      end

      # Records an SQL query, potentially creating a new slow SQL trace, or
      # aggregating the query into an existing slow SQL trace.
      #
      # This method should be used only by gem authors wishing to extend
      # the Ruby agent to instrument new database interfaces - it should
      # generally not be called directly from application code.
      #
      # @param sql [String] the SQL query being recorded
      # @param metric_name [String] is the metric name under which this query will be recorded
      # @param config [Object] is the driver configuration for the connection
      # @param duration [Float] number of seconds the query took to execute
      # @param explainer [Proc] for internal use only - 3rd-party clients must
      #                         not pass this parameter.
      #
      # @api public
      #
      def notice_sql(sql, metric_name, config, duration, state=nil, &explainer) #THREAD_LOCAL_ACCESS sometimes
        state ||= TransactionState.tl_get
        data = state.sql_sampler_transaction_data
        return unless data

        if state.is_sql_recorded?
          if duration > Agent.config[:'slow_sql.explain_threshold']
            backtrace = caller.join("\n")
            data.sql_data << SlowSql.new(Database.capture_query(sql),
                                         metric_name, config,
                                         duration, backtrace, &explainer)
          end
        end
      end

      def merge!(sql_traces)
        @samples_lock.synchronize do
          sql_traces.each do |trace|
            existing_trace = @sql_traces[trace.sql]
            if existing_trace
              existing_trace.aggregate_trace(trace)
            else
              @sql_traces[trace.sql] = trace
            end
          end
        end
      end

      def harvest!
        return [] unless enabled?

        result = []
        @samples_lock.synchronize do
          result = @sql_traces.values
          @sql_traces = {}
        end
        slowest = result.sort{|a,b| b.max_call_time <=> a.max_call_time}[0,10]
        slowest.each {|trace| trace.prepare_to_send }
        slowest
      end

      def reset!
        @samples_lock.synchronize do
          @sql_traces = {}
        end
      end
    end

    class TransactionSqlData
      attr_reader :path
      attr_reader :uri
      attr_reader :sql_data
      attr_reader :guid

      def initialize
        @sql_data = []
      end

      def set_transaction_info(uri, guid)
        @uri = uri
        @guid = guid
      end

      def set_transaction_name(name)
        @path = name
      end
    end

    class SlowSql
      attr_reader :sql
      attr_reader :metric_name
      attr_reader :duration
      attr_reader :backtrace

      def initialize(sql, metric_name, config, duration, backtrace=nil,
                     &explainer)
        @sql = sql
        @metric_name = metric_name
        @config = config
        @duration = duration
        @backtrace = backtrace
        @explainer = explainer
      end

      def obfuscate
        NewRelic::Agent::Database.obfuscate_sql(@sql)
      end

      def normalize
        NewRelic::Agent::Database::Obfuscator.instance \
          .default_sql_obfuscator(@sql).gsub(/\?\s*\,\s*/, '').gsub(/\s/, '')
      end

      def explain
        if @config && @explainer
          NewRelic::Agent::Database.explain_sql(@sql, @config, &@explainer)
        end
      end

      # We can't serialize the explainer, so clear it before we transmit
      def prepare_to_send
        @explainer = nil
      end
    end

    class SqlTrace < Stats
      attr_reader :path
      attr_reader :url
      attr_reader :sql_id
      attr_reader :sql
      attr_reader :database_metric_name
      attr_reader :params
      attr_reader :slow_sql

      def initialize(normalized_query, slow_sql, path, uri)
        super()
        @params = {}
        @sql_id = consistent_hash(normalized_query)
        set_primary slow_sql, path, uri
        record_data_point(float(slow_sql.duration))
      end

      def set_primary(slow_sql, path, uri)
        @slow_sql = slow_sql
        @sql = slow_sql.sql
        @database_metric_name = slow_sql.metric_name
        @path = path
        @url = uri
        @params[:backtrace] = slow_sql.backtrace if slow_sql.backtrace
      end

      def aggregate(slow_sql, path, uri)
        if slow_sql.duration > max_call_time
          set_primary slow_sql, path, uri
        end

        record_data_point(float(slow_sql.duration))
      end

      def aggregate_trace(trace)
        aggregate(trace.slow_sql, trace.path, trace.url)
      end

      def prepare_to_send
        params[:explain_plan] = @slow_sql.explain if need_to_explain?
        @sql = @slow_sql.obfuscate if need_to_obfuscate?
        @slow_sql.prepare_to_send
      end

      def need_to_obfuscate?
        Agent.config[:'slow_sql.record_sql'].to_s == 'obfuscated'
      end

      def need_to_explain?
        Agent.config[:'slow_sql.explain_enabled']
      end

      include NewRelic::Coerce

      def to_collector_array(encoder)
        [ string(@path),
          string(@url),
          int(@sql_id),
          string(@sql),
          string(@database_metric_name),
          int(@call_count),
          Helper.time_to_millis(@total_call_time),
          Helper.time_to_millis(@min_call_time),
          Helper.time_to_millis(@max_call_time),
          encoder.encode(@params) ]
      end

      private

      def consistent_hash(string)
        # need to hash the same way in every process
        Digest::MD5.hexdigest(string).hex \
          .modulo(2**31-1)  # ensure sql_id fits in an INT(11)
      end
    end
  end
end
