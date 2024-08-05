# frozen_string_literal: true
class Antiafk < Sandbox::Script
  CHECKCON_INTERVAL = 60
  AUTH_INTERVAL_MIN = 840
  AUTH_INTERVAL_ADD = 180

  def main
    checkcon_last = auth_last = auth_interval = 0
    connected = true

    loop do
      begin
        if connected
          if (Time.now - auth_last).to_i >= auth_interval
            @game.auth
            @game.player.load
            auth_last = Time.now
            auth_interval = AUTH_INTERVAL_MIN + rand(AUTH_INTERVAL_ADD)
            @logger.log("Autenticación exitosa. Intervalo de autenticación actualizado a #{auth_interval} segundos")
          end

          if (Time.now - checkcon_last).to_i >= CHECKCON_INTERVAL
            @game.check_connectivity
            checkcon_last = Time.now
          end
        else
          @logger.log("Reconectando...")
          begin
            @game.reconnect
            connected = true
            @logger.log("Reconexión exitosa")
          rescue StandardError => e
            @logger.error("Error de reconexión: #{e}")
            sleep(10)
          end
        end
      rescue Hackers::RequestError => e
        @logger.error("Error de request: #{e}")
        connected = false
        sleep(10)
      rescue StandardError => e
        @logger.error("Error: #{e}")
        connected = false
        sleep(10)
      ensure
        sleep(1)
      end
    end
  end
end