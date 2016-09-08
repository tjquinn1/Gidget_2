# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that the closing brace in a method call is
      # symmetrical with respect to the opening brace and the method
      # arguments.
      #
      # If a method call's opening brace is on the same line as the
      # first argument of the call, then the closing brace should be
      # on the same line as the last argument of the call.
      #
      # If a method call's opening brace is on a separate line from
      # the first argument of the call, then the closing brace should
      # be on the line after the last argument of the call.
      #
      # @example
      #
      #     # bad
      #     foo(a,
      #       b
      #       )
      #
      #     # bad
      #     foo(
      #       a,
      #       b)
      #
      #     # good
      #     foo(a,
      #       b)
      #
      #     #good
      #     foo(
      #       a,
      #       b
      #     )
      class MultilineMethodCallBraceLayout < Cop
        include MultilineLiteralBraceLayout

        SAME_LINE_MESSAGE = 'Closing method call brace must be on the ' \
          'same line as the last argument when opening brace is on the same ' \
          'line as the first argument.'.freeze

        NEW_LINE_MESSAGE = 'Closing method call brace must be on the ' \
          'line after the last argument when opening brace is on a separate ' \
          'line from the first argument.'.freeze

        def on_send(node)
          check_brace_layout(node)
        end

        private

        def children(node)
          _receiver, _method_name, *args = *node

          args
        end
      end
    end
  end
end
