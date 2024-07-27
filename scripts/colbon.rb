class Colbon < Sandbox::Script
  INTERVAL_MIN = 300
  INTERVAL_ADD = 120

  def main
    unless @game.connected?
      @logger.log(NOT_CONNECTED)
      return
    end

    loop do
      @logger.log("Cargando jugador...")
      @game.player.load unless @game.player.loaded?

      @logger.log("Cargando mundo...")
      @game.world.load

      bonuses = @game.world.bonuses.to_a

      @logger.log("Recolectando bonificaciones...")
      bonuses.each do |bonus|
        bonus.amount = 15_000
        bonus.collect
        @logger.log("Bonus #{bonus.id} collected with #{bonus.amount} credits")
      end

      rescue Hackers::RequestError => e
        @logger.error(e)

      ensure
        time_left = INTERVAL_MIN + rand(INTERVAL_ADD)
        @logger.log("Esperando #{time_left} segundos...")
        time_left.times do |i|
          @logger.log("Tiempo restante: #{time_left - i} segundos")
          sleep(1)
        end
    end
  end
end