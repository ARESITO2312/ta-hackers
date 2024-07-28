class Hackers::World::Bonus
  attr_accessor :id, :amount

  def initialize(id, amount)
    @id = id
    @amount = amount
  end

  def collect
    # Código para recolectar la bonificación
  end

  def amount=(value)
    @amount = value
  end
end

class Colbon < Sandbox::Script
  INTERVAL_MIN = 60
  INTERVAL_ADD = 0

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
      sleep(time_left)
    end
  end
end