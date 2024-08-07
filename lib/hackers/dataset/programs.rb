# frozen_string_literal: true

class Autohack < Sandbox::Script
  BLACKLIST = [127]
  TIMEOUT = 300

  def main
    if @args[0].nil?
      @logger.log('Specify the number of hosts')
      return
    end

    unless @game.connected?
      @logger.log(NOT_CONNECTED)
      return
    end

    n = 0
    @game.world.load
    targets = @game.world.targets
    @logger.log("Loaded #{targets.count} targets")

    @game = Hackers::Game.new(@game.world)

    loop do
      targets.each do |target|
        k = (link unavailable)
        @logger.log("Target ID: #{k}")

        next if BLACKLIST.include?(k)
        next if target.nil? || (link unavailable).nil?

        @logger.log("Attacking target ID: #{k}")
        @logger.log("Attack #{k} / #{target.name}")

        begin
          net = @game.cmd('NetGetForAttack', target_id: k)
          @logger.log("Got net for attack")

          # Deja el ion cannon en la toma de red
          @logger.log("Leaving ion cannon on target ID: #{k}")
          @game.cmdFight(k, { nodes: 'ion_cannon' })
          @game.cmdNetLeave(k)

          @logger.log("Left network")

          n += 1
          @logger.log("Attack count: #{n}")

          return if n == @args[0].to_i
          return if Time.now - @start_time > TIMEOUT

          sleep(rand(15..25))
        rescue => e
          @logger.error(e)
          @logger.log("Error attacking target ID: #{k}")
          sleep(rand(165..295))
        end
      end

      begin
        targets.new
      rescue Hackers::RequestError => e
        if e.type == 'Net::ReadTimeout'
          @logger.error('Get new targets timeout')
          retry
        end
        @logger.error("Get new targets (#{e})")
        return
      end
    end
  end
end