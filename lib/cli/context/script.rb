# frozen_string_literal: true
require_relative 'base'

module Hackers
  module CLI
    module Context
      class Script < Base
        def initialize(parent)
          super(parent)
          @script = nil
          @reading = false
        end

        def run
          loop do
            break if terminated?

            @reading = true
            input = Readline.readline('/script > ', true)
            @reading = false

            break unless input
            input.strip!

            case input.downcase
            when /^run\s+(.+)/
              name = $1
              @script = @parent.api.script_get(name)
              if @script
                puts "✅ Ejecutando: #{@script.name}"
                Thread.new { script_listen }
              else
                puts "❌ Script no encontrado"
              end
            when 'list'
              list = @parent.api.scripts_list
              puts "Scripts disponibles:"
              list.each { |s| puts "  #{s[:id]} - #{s[:name]}" }
            when 'stop'
              @script = nil
              puts "✅ Detenido"
            when 'exit', 'quit'
              terminate
              break
            else
              puts "❌ Comando desconocido"
              puts "Comandos: run [nombre/id], list, stop, exit"
            end
          end
        end

        private

        def script_listen
          until terminated? || @script.nil?
            begin
              line = @script.read_line
              puts line if line
              # ✅ Protección definitiva
              if @reading
                begin
                  Readline.refresh_line if Readline.respond_to?(:refresh_line)
                rescue StandardError
                end
              end
            rescue StandardError
              sleep 1
            end
            sleep 0.3
          end
        end
      end
    end
  end
end
