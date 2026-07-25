# frozen_string_literal: true
require_relative 'base'

module Hackers
  module CLI
    module Context
      class Chat < Base
        def initialize(parent, room = nil)
          super(parent)
          @room = room
          @reading = false
        end

        def run
          return unless @room
          t1 = Thread.new { chat_log }
          t2 = Thread.new { chat_read }
          t1.join
          t2.join
        end

        private

        def chat_log
          loop do
            break if terminated?
            begin
              @room.read.each do |m|
                puts "[#{m.datetime}] #{m.name}: #{m.message}"
                # ✅ SOLO cambiamos ESTA línea, nada más
                if @reading
                  begin
                    Readline.refresh_line if Readline.respond_to?(:refresh_line)
                  rescue StandardError; end
                end
              end
            rescue StandardError
              sleep 1
            end
            sleep 0.3
          end
        end

        def chat_read
          loop do
            break if terminated?
            @reading = true
            inp = Readline.readline('/chat > ', true)
            @reading = false
            break unless inp
            terminate if inp.downcase == 'exit' || inp == '..'
            @room.send(inp.strip) unless terminated?
          end
        end
      end
    end
  end
end
