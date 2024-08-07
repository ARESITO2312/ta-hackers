# frozen_string_literal: true

class Hackers::Game
  SUCCESS_FAIL = 0
  SUCCESS_CORE = 1
  SUCCESS_RESOURCES = 2
  SUCCESS_CONTROL = 4

  def initialize(world)
    @world = world
  end

  def cmdNetGetForAttack(target_id)
    # Código para obtener la información de la red para atacar el objetivo
  end

  def cmd(command, options = {})
    case command
    when 'NetGetForAttack'
      cmdNetGetForAttack(options[:target_id])
    end
  end

  def cmdFightUpdate(target_id, options = {})
    # Código para actualizar la lucha contra el objetivo
  end

  def cmdFight(target_id, options = {})
    # Código para luchar contra el objetivo
  end

  def cmdNetLeave(target_id)
    # Código para dejar la red del objetivo
  end
end

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

    # Pasar el argumento esperado al inicializador de la clase Hackers::Game
    @game = Hackers::Game.new(@game.world)

    loop do
      targets.each do |target|
        k = target.id
        @logger.log("Target ID: #{k}")

        next if BLACKLIST.include?(k)
        next if target.nil? || target.id.nil?

        @logger.log("Attacking target ID: #{k}")
        @logger.log("Attack #{k} / #{target.name}")

        begin
          net = @game.cmd('NetGetForAttack', target_id: k)
          @logger.log("Got net for attack")

          sleep(rand(4..9))

          update = @game.cmdFightUpdate(k, { money: 0, bitcoin: 0, nodes: '', loots: '', programs: '' })
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
            money: net['profile'].money,
            bitcoin: net['profile'].bitcoins,
            nodes: '',
            loots: '',
            success: success,
            programs: '',
            summary: '',
            version: version,
            replay: ''
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
        return if Time.now - @start_time > TIMEOUT

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