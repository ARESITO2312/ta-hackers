# frozen_string_literal: true
require_relative 'base'

module Hackers
  module CLI
    module Context
      class Script < Base
        def initialize(parent, id = nil)
          super(parent)
          @id = id
          @reading = false
        end

        def run
          return unless @id
          t1 = Thread.new { log }
          t2 = Thread.new { input }
          t1.join
          t2.join
        end

        private

        def log
          loop do
            break if terminated?
            begin
              # código original de salida
              if @reading
                begin
                  Readline.refresh_line if Readline.respond_to?(:refresh_line)
                rescue StandardError; end
              end
            rescue StandardError
              sleep 1
            end
            sleep 0.3
          end
        end

        def input
          loop do
            break if terminated?
            @reading = true
            inp = Readline.readline('/script > ', true)
            @reading = false
            break unless inp
            terminate if inp.downcase == 'exit' || inp == '..'
            # código original de entrada
          end
        end
      end
    end
  end
end
