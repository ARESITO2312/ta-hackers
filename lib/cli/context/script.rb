
# frozen_string_literal: true
require_relative 'base'

module Hackers
  module CLI
    module Context
      class Script < Base
        SCRIPTS_FOLDER = File.expand_path('../../../scripts', __dir__)

        def initialize(parent)
          super(parent)
          @script = nil
          @reading = false
          @all_scripts = cargar_scripts_locales
        end

        def run
          loop do
            break if terminated?
            @reading = true
            input = Readline.readline('/script > ', true)
            @reading = false
            break unless input
            input.strip!
            cmd = input.downcase

            case cmd
            # === EJECUTAR ===
            when /^run\s+(.+)/, /^start\s+(.+)/
              objetivo = $1.strip
              # Busca primero en servidor, luego en carpeta local
              @script = buscar_ejecutar(objetivo)
              if @script
                puts "✅ Ejecutando: #{@script[:nombre] || objetivo}"
                Thread.new { leer_salida }
              else
                puts "❌ No encontrado: #{objetivo}"
              end

            # === LISTAR TODOS ===
            when 'list', 'all', 'ls'
              puts "📂 Scripts en carpeta:"
              if Dir.exist?(SCRIPTS_FOLDER)
                Dir.glob("#{SCRIPTS_FOLDER}/*.rb").each do |f|
                  nom = File.basename(f, '.rb')
                  puts "  📄 #{nom}"
                end
              end
              puts "\n📂 Scripts del servidor:"
              serv = @parent.api.scripts_list rescue []
              serv.each { |s| puts "  📶 #{s[:id]} | #{s[:name]}" }

            # === DETALLES ===
            when /^info\s+(.+)/, /^about\s+(.+)/
              nom = $1.strip
              s = @parent.api.script_get(nom) rescue nil
              if s
                puts "📋 #{s.name}"
                puts "   ID: #{s.id}"
                puts "   Nivel: #{s.level}"
                puts "   Descripción: #{s.description}"
              elsif File.exist?("#{SCRIPTS_FOLDER}/#{nom}.rb")
                puts "📋 Local: #{nom}"
                puts "   Ruta: #{SCRIPTS_FOLDER}/#{nom}.rb"
              else
                puts "❌ No existe"
              end

            # === CONTROL ===
            when 'stop', 'end', 'cancel'
              detener
              puts "✅ Detenido"
            when 'pause', 'suspend'
              @script&.dig(:objeto)&.pause rescue nil
              puts "⏸️ Pausado"
            when 'resume', 'continue'
              @script&.dig(:objeto)&.resume rescue nil
              puts "▶️ Reanudado"
            when 'restart', 'reiniciar'
              obj_antiguo = @script
              detener
              @script = buscar_ejecutar(obj_antiguo[:nombre]) if obj_antiguo
              puts "🔄 Reiniciado"

            # === ESTADO ===
            when 'status', 'state'
              if @script
                puts "🔴 En ejecución: #{@script[:nombre]}"
                puts "   Progreso: #{@script[:progreso] || '0'}%"
                puts "   Tipo: #{@script[:tipo] || 'desconocido'}"
              else
                puts "⚪ Ninguno activo"
              end

            # === UTILIDADES ===
            when 'reload', 'recargar'
              @all_scripts = cargar_scripts_locales
              puts "🔄 Lista actualizada"
            when 'path', 'ruta'
              puts "📂 Carpeta: #{SCRIPTS_FOLDER}"
            when 'clear', 'cls'
              system('clear')
            when 'exit', 'quit', 'back', '..'
              detener
              terminate
              break
            when 'help', 'ayuda'
              puts "📚 COMANDOS:"
              puts "  run/start [nombre/id] → Ejecutar"
              puts "  list/all/ls           → Ver todos"
              puts "  info/about [nombre]   → Detalles"
              puts "  stop/end              → Detener"
              puts "  pause/resume          → Pausar/Continuar"
              puts "  restart               → Reiniciar"
              puts "  status                → Ver estado"
              puts "  reload                → Actualizar lista"
              puts "  path                  → Ver carpeta"
              puts "  clear/cls             → Limpiar"
              puts "  exit/..               → Salir"
            else
              puts "❌ Desconocido. Usa help"
            end
          end
        end

        private

        def cargar_scripts_locales
          return [] unless Dir.exist?(SCRIPTS_FOLDER)
          Dir.glob("#{SCRIPTS_FOLDER}/*.rb").map do |arch|
            { nombre: File.basename(arch, '.rb'), ruta: arch }
          end
        end

        def buscar_ejecutar(nombre)
          # Primero busca en servidor
          serv = @parent.api.script_get(nombre) rescue nil
          return { nombre: serv.name, tipo: 'servidor', objeto: serv } if serv

          # Luego busca en carpeta local
          local = @all_scripts.find { |s| s[:nombre].downcase == nombre.downcase }
          return { nombre: local[:nombre], tipo: 'local', ruta: local[:ruta] } if local

          nil
        end

        def detener
          @script&.dig(:objeto)&.stop rescue nil
          @script = nil
        end

        def leer_salida
          until terminated? || @script.nil?
            begin
              if @script[:tipo] == 'servidor'
                linea = @script[:objeto].read_line
                puts linea if linea
              elsif @script[:tipo] == 'local'
                # Ejecutar script local si se requiere
              end

              # ✅ Protección definitiva
              if @reading
                begin
                  Readline.refresh_line if Readline.respond_to?(:refresh_line)
                rescue StandardError; end
              end
            rescue StandardError
              sleep 1
            end
            sleep 0.25
          end
        end
      end
    end
  end
end
