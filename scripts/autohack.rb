# frozen_string_literal: true

class Autohack < Sandbox::Script
  BLACKLIST = [127]

  def main
    @logger.log("Iniciando autohack")

    if @args[0].nil?
      @logger.log("Specify the number of hosts")
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

    loop do
      targets.each do |target|
        k = target.id
        @logger.log("Target ID: #{k}")

        next if BLACKLIST.include?(k)
        next if target.nil? || k.nil?

        @logger.log("Attack #{k} / #{target.name}")

        begin
          net = @game.cmdNetGetForAttack(k)
          @logger.log("Got net for attack")

          sleep(rand(4..9))

          update = @game.cmdFightUpdate(k, {
            'money' => 0,
            'bitcoin' => 0,
            'nodes' => '',
            'loots' => '',
            'success' => Hackers::Game::SUCCESS_FAIL,
            'programs' => ''
          })
          @logger.log("Updated fight")

          sleep(rand(35..95))

          version = [
            @game.config['version'],
            @game.app_settings.get('node types'),
            @game.app_settings.get('program types'),
          ].join(',')

          @logger.log("Version: #{version}")

          success = Hackers::Game::SUCCESS_CORE | Hackers::Game::SUCCESS_RESOURCES | Hackers::Game::SUCCESS_CONTROL

          fight = @game.cmdFight(k, {
            'money' => net['profile'] ? net['profile'].money : 0,
            'bitcoin' => net['profile'] ? net['profile'].bitcoins : 0,
            'nodes' => '',
            'loots' => '',
            'success' => success,
            'programs' => '',
            'summary' => '',
            'version' => version,
            'replay' => ''
          })
          @logger.log("Fought")

          sleep(rand(5..12))

          leave = @game.cmdNetLeave(k)
          @logger.log("Left network")

          @game.player.load

        rescue => e
          @logger.error(e)
          @logger.log("Error attacking target ID: #{k}")

          sleep(rand(165..295))

          next
        end

        n += 1
        @logger.log("Attack count: #{n}")

        return if n == @args[0].to_i

        sleep(rand(15..25))
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