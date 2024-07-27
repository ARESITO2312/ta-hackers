class SpamBot < Sandbox::Script
  def main
    message = "Mensaje de spam"
    count = 10
    delay = 1 # segundos entre mensajes

    @logger.log("Iniciando spam con mensaje: #{message}, cantidad: #{count}")

    count.times do |i|
      @logger.log("Enviando mensaje #{i+1}/#{count}: #{message}")
      @game.chat.send_message(message)
      sleep(delay)
    end

    @logger.log("Spam finalizado")
  end
end