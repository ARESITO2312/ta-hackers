# frozen_string_literal: true

require_relative 'base'

module Hackers
  module CLI
    module Context
      ##
      # Script execution context
      class Script < Base
        def initialize(parent, script_id = nil)
          super(parent)
          @script_id = script_id
          @reading = false
        end

        def run
          return unless @script_id

          thread_log = Thread.new { script_log }
          thread_read = Thread.new { script_read }

          thread_log.join
          thread_read.join
        end

        def script_log
          loop do
            break if terminated?

            begin
              # Aquí va la lógica que muestra la salida del script
              # (mantén el código original de lectura/impresión)
              # ...

              # ✅ Protección definitiva contra el error de refresh_line
              if @reading
                begin
                  Readline.refresh_line if Readline.respond_to?(:refresh_line)
                rescue StandardError
                  # Ignora sin detener la ejecución
                end
              end
            rescue StandardError
              sleep 1
              next
            end

            sleep 0.3
          end
        end

        def script_read
          loop do
            break if terminated?

            @reading = true
            input = Readline.readline('/script > ', true)
            @reading = false

            break unless input

            input.strip!
            next if input.empty?

            if input.downcase == 'exit'
              terminate
              break
            end

            # Aquí va la lógica de enviar comandos al script
            # ...
          end
        end
      end
    end
  end
end
