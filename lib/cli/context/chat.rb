# frozen_string_literal: true
require_relative 'base'

module Hackers
  module CLI
    module Context
      class Chat < Base
        def initialize(parent)
          super(parent)
          @room = nil
          @reading = false
        end

        def run
          loop do
            break if terminated?

            @reading = true
            input = Readline.readline('/chat > ', true)
            @reading = false

            break unless input
            input.strip!

            case input.downcase
            when /^open\s+(\d+)/
              room_id = $1
              @room = @parent.api.chat_join(room_id)
              puts "✅ Conectado a sala #{room_id}"
              # Arranca el lector de mensajes en segundo plano
              Thread.new { chat_listen }
            when 'list'
              rooms = @parent.api.chat_rooms
              puts "Salas disponibles:"
              rooms.each { |r| puts "  #{r[:id]} - #{r[:name]}" }
            when 'users'
              if @room
                users = @room.users
                puts "Usuarios en sala:"
                users.each { |u| puts "  #{u[:name]} (ID: #{u[:id]})" }
              else
                puts "❌ No estás en ninguna sala"
              end
            when 'exit', 'quit'
              terminate
              break
            else
              if @room && !input.empty?
                @room.send(input)
              else
                puts "❌ Comando desconocido o no estás en sala"
                puts "Comandos: open [ID], list, users, exit"
              end
            end
          end
        end

        private

        def chat_listen
          until terminated?
            begin
              @room.read.each do |msg|
                puts "[#{msg.datetime}] #{msg.name}: #{msg.message}"
                # ✅ Protección definitiva
                if @reading
                  begin
                    Readline.refresh_line if Readline.respond_to?(:refresh_line)
                  rescue StandardError
                    # Sin romper nada
                  end
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
