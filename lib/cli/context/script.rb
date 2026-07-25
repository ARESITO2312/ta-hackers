# frozen_string_literal: true

require_relative 'base'

module Hackers
  module CLI
    module Context
      ##
      # Script execution context
      class Script < Base
        def initialize(parent)
          super(parent)
          @script = nil
          @reading = false
        end

        def run
          return unless @script

          thr_log = Thread.new { script_log }
          thr_in  = Thread.new { script_input }

          thr_log.join
          thr_in.join
        end

        def commands
          {
            'run'   => 'Run script by ID or name',
            'list'  => 'List available scripts',
            'stop'  => 'Stop running script',
            'info'  => 'Show script details',
            'quit'  => 'Exit script context'
          }
        end

        def exec(cmd, args)
          case cmd.downcase
          when 'run'
            script_run(args.join(' '))
          when 'list'
            script_list
          when 'stop'
            script_stop
          when 'info'
            script_info(args.join(' '))
          when 'quit', 'exit'
            terminate
          else
            parent.exec(cmd, args)
          end
        end

        private

        def script_list
          list = @parent.api.scripts_list
          puts "Available scripts:"
          list.each do |s|
            puts "  #{s[:id]} - #{s[:name]}"
          end
        end

        def script_run(name)
          @script = @parent.api.script_get(name)
          unless @script
            puts "Script not found: #{name}"
            return
          end
          puts "Running script: #{@script.name}"
          run
        end

        def script_stop
          terminate if @script
          puts "Script stopped"
        end

        def script_info(name)
          s = @parent.api.script_get(name)
          return puts "Script not found" unless s
          puts "ID: #{s.id}"
          puts "Name: #{s.name}"
          puts "Description: #{s.description}"
        end

        def script_log
          loop do
            break if terminated? || !@script

            begin
              line = @script.read_line
              puts line if line
              
              # ✅ Protección definitiva sin perder comandos
              if @reading
                begin
                  Readline.refresh_line if Readline.respond_to?(:refresh_line)
                rescue StandardError
                  # Ignora sin romper
                end
              end
            rescue StandardError => e
              puts "Error: #{e.message}"
              sleep 1
            end
            sleep 0.2
          end
        end

        def script_input
          loop do
            break if terminated? || !@script

            @reading = true
            input = Readline.readline('/script > ', true)
            @reading = false

            break unless input
            input.strip!

            if input.downcase == 'exit'
              terminate
              break
            end

            @script.send_input(input)
          end
        end
      end
    end
  end
end
