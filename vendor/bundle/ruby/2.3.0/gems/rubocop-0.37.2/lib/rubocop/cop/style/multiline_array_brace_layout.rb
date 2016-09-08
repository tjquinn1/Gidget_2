# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that the closing brace in an array literal is
      # symmetrical with respect to the opening brace and the array
      # elements.
      #
      # If an array's opening brace is on the same line as the first element
      # of the array, then the closing brace should be on the same line as
      # the last element of the array.
      #
      # If an array's opening brace is on a separate line from the first
      # element of the array, then the closing brace should be on the line
      # after the last element of the array.
      #
      # @example
      #
      #     # bad
      #     [ :a,
      #       :b
      #     ]
      #
      #     # bad
      #     [
      #       :a,
      #       :b ]
      #
      #     # good
      #     [ :a,
      #       :b ]
      #
      #     #good
      #     [
      #       :a,
      #       :b
      #     ]
      class MultilineArrayBraceLayout < Cop
        include MultilineLiteralBraceLayout

        SAME_LINE_MESSAGE = 'Closing array brace must be on the same line as ' \
          'the last array element when opening brace is on the same line as ' \
          'the first array element.'.freeze

        NEW_LINE_MESSAGE = 'Closing array brace must be on the line after ' \
          'the last array element when opening brace is on a separate line ' \
          'from the first array element.'.freeze

        def on_array(node)
          check_brace_layout(node)
        end
      end
    end
  end
end
