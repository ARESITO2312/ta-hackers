# frozen_string_literal: true
class Antiafk < Sandbox::Script
  CHECKCON_INTERVAL = 60
  AUTH_INTERVAL_MIN = 840
  AUTH_INTERVAL_ADD = 180

  def main
    checkcon_last = auth_last = auth_interval = 0

    @logger.log("Iniciando script Antiafk")

    loop do
      @logger.log("Verificando si es hora de autenticar...")
      if (Time.now - auth_last).to_i >= auth_interval
        @logger.log("Autenticando...")
        @game.auth
        @game.player.load
        auth_last = Time.now
        auth_interval = AUTH_INTERVAL_MIN + rand(AUTH_INTERVAL_ADD)
        @logger.log("Autenticación exitosa. Intervalo de autenticación actualizado a #{auth_interval} segundos")
      end

      @logger.log("Verificando conectividad...")
      if (Time.now - checkcon_last).to_i >= CHECKCON_INTERVAL
        @logger.log("Verificando conectividad...")
        @game.check_connectivity
        checkcon_last = Time.now
        @logger.log("Conectividad verificada con éxito")
      end

    rescue Hackers::RequestError => e
      @logger.error("Error de request: #{e}")
      sleep(10)
    ensure
      sleep(1)
    end
  end
end