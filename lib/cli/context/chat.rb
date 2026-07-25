# frozen_string_literal: true

require_relative 'base'

module Hackers
  module CLI
    module Context
      ##
      # Chat context
      class Chat < Base
        def initialize(parent)
          super(parent)
          @room = nil
          @reading = false
        end

        def run
          return unless @room

          thr_log = Thread.new { chat_log }
          thr_in  = Thread.new { chat_input }

          thr_log.join
          thr_in.join
        end

        def commands
          {
            'open'   => 'Open chat room by ID',
            'list'   => 'List available rooms',
            'users'  => 'Show users in current room',
            'send'   => 'Send message',
            'quit'   => 'Exit chat context'
          }
        end

        def exec(cmd, args)
          case cmd.downcase
          when 'open'
            chat_open(args.first)
          when 'list'
            chat_list
          when 'users'
            chat_users
          when 'send'
            chat_send(args.join(' '))
          when 'quit', 'exit'
            terminate
          else
            parent.exec(cmd, args)
          end
        end

        private

        def chat_list
          rooms = @parent.api.chat_rooms
          puts "Available rooms:"
          rooms.each { |r| puts "  #{r[:id]} - #{r[:name]}" }
        end

        def chat_open(room_id)
          return puts "Room ID required" unless room_id
          @room = @parent.api.chat_join(room_id)
          puts "Joined room: #{@room.name}"
          run
        end

        def chat_users
          return puts "Not in any room" unless @room
          users = @room.users
          puts "Users in room:"
          users.each { |u| puts "  #{u[:name]} (ID: #{u[:id]})" }
        end

        def chat_send(text)
          return puts "No message text" if text.to_s.strip.empty?
          return puts "Not in any room" unless @room
          @room.send(text)
        end

        def chat_log
          loop do
            break if terminated? || !@room

            begin
              msg = @room.read_next
              if msg
                puts "[#{msg.datetime}] #{msg.name}: #{msg.message}"
              end

              # ✅ Protección definitiva
              if @reading
                begin
                  Readline.refresh_line if Readline.respond_to?(:refresh_line)
                rescue StandardError
                  # Ignora sin romper
                end
              end
            rescue StandardError => e
              puts "Chat error: #{e.message}"
              sleep 1
            end
            sleep 0.3
          end
        end

        def chat_input
          loop do
            break if terminated? || !@room

            @reading = true
            input = Readline.readline('/chat > ', true)
            @reading = false

            break unless input
            input.strip!

            if input.downcase == 'exit'
              terminate
              break
            end

            chat_send(input) unless input.empty?
          end
        end
      end
    end
  end
end
