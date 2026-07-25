# frozen_string_literal: true

module Hackers
  module CLI
    module Context
      ##
      # Base context
      class Base
        attr_reader :parent, :terminated

        def initialize(parent)
          @parent = parent
          @terminated = false
        end

        def terminate
          @terminated = true
        end

        def terminated?
          @terminated
        end

        def run; end
      end
    end
  end
end
