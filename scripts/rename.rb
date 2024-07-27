# Definición de la clase Trickster
class Trickster
  # Definición de la clase Hackers
  module Hackers
    # Definición de la clase RequestError
    class RequestError < StandardError
    end
  end
end

# Definición de la clase Rename
class Rename < Sandbox::Script
  def main
    @logger.log("Iniciando script Rename")

    if @args[0].nil?
      @logger.log("Error: ID no especificado")
      return
    end

    id = @args[0].to_i
    name = @args[1]
    name = "" if name.nil?

    begin
      @logger.log("Intentando cambiar nombre para ID #{id} a #{name}")
      @game.cmdPlayerSetName(id, name)
      @logger.log("Nombre cambiado con éxito")
    rescue Trickster::Hackers::RequestError => e
      @logger.error("Error al cambiar nombre: #{e}")
      return
    end

    msg = if name.empty?
            "Nombre para #{id} borrado"
          else
            "Nombre para #{id} establecido a #{name}"
          end

    @logger.log(msg)
  end
end