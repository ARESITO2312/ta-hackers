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
            cmd = input.downcase

            case cmd
            # === ENTRAR / UNIRSE ===
            when /^open\s+(\d+)/, /^join\s+(\d+)/
              id_sala = $1
              @room = @parent.api.chat_join(id_sala)
              puts "✅ Unido a sala ##{id_sala}"
              Thread.new { escuchar_mensajes }

            # === VER SALAS ===
            when 'list', 'rooms', 'salas'
              salas = @parent.api.chat_rooms rescue []
              puts "📋 Salas disponibles:"
              salas.each { |s| puts "  ##{s[:id]} - #{s[:name]}" }

            # === VER USUARIOS ===
            when 'users', 'who', 'jugadores'
              if @room
                us = @room.users rescue []
                puts "👥 En esta sala:"
                us.each { |u| puts "  #{u[:name]} | Nivel #{u[:rank]}" }
              else
                puts "❌ Primero entra a una sala con open [ID]"
              end

            # === ENVIAR MENSAJES ===
            when /^say\s+(.+)/, /^msg\s+(.+)/, /^decir\s+(.+)/
              texto = $1
              if @room && !texto.empty?
                @room.send(texto)
                puts "✓ Enviado"
              else
                puts "❌ No estás en ninguna sala"
              end

            # === TU PERFIL ===
            when 'me', 'whoami', 'yo'
              yo = @parent.api.profile rescue nil
              if yo
                puts "👤 Tu perfil:"
                puts "   Nombre: #{yo.name}"
                puts "   ID: #{yo.id}"
                puts "   Rango: #{yo.rank}"
              end

            # === UTILIDADES ===
            when 'clear', 'cls', 'limpiar'
              system('clear')
            when 'exit', 'quit', 'salir', 'back', '..'
              terminate
              break
            when 'help', 'ayuda', 'comandos'
              puts "💬 COMANDOS DEL CHAT:"
              puts "  open/join [ID]   → Entrar a sala"
              puts "  list/rooms       → Ver salas"
              puts "  users/who        → Ver quién está ahí"
              puts "  say/msg [texto]  → Enviar mensaje"
              puts "  me/yo            → Ver tus datos"
              puts "  clear/cls        → Limpiar pantalla"
              puts "  exit/..          → Salir del chat"
              puts "  (solo texto)     → Enviar directamente"
            else
              # Si no es comando, envía el texto como mensaje
              if @room && !input.empty?
                @room.send(input)
              else
                puts "❌ Comando desconocido. Escribe help"
              end
            end
          end
        end

        private

        def escuchar_mensajes
          until terminated?
            begin
              mensajes = @room.read rescue []
              mensajes.each do |m|
                puts "[#{m.datetime}] #{m.name} (#{m.rank}): #{m.message}"
                # ✅ Protección definitiva
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
      end
    end
  end
end
