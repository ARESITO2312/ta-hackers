# frozen_string_literal: true

module Hackers
  module CLI
    module Context
      ##
      # Chat context
      class Chat < Base
        attr_reader :room

        def initialize(parent, room = nil)
          super(parent)
          @room = room
          @reading = false
        end

        def run
          return unless @room

          thread_log = Thread.new { chat_log }
          thread_read = Thread.new { chat_read }

          thread_log.join
          thread_read.join
        end

        def chat_log
          loop do
            break if terminated?

            begin
              @room.read.each do |msg|
                next if msg.message.to_s.strip.empty?

                puts "[#{msg.datetime}] #{msg.name}: #{msg.message}"
                # Protección segura para la función que falla
                if @reading
                  begin
                    Readline.refresh_line if Readline.respond_to?(:refresh_line)
                  rescue StandardError
                    # Ignora sin romper
                  end
                end
              end
            rescue StandardError
              sleep 1
              next
            end

            sleep 0.3
          end
        end

        def chat_read
          loop do
            break if terminated?

            @reading = true
            input = Readline.readline('/chat > ', true)
            @reading = false

            break unless input

            input.strip!
            next if input.empty?

            terminate if input.downcase == 'exit'
            break if terminated?

            begin
              @room.send(input)
            rescue StandardError
              puts "❌ No se pudo enviar el mensaje"
            end
          end
        end
      end
    end
  end
end
