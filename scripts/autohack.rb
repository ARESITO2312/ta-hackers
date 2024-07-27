module Hackers
  class Game
    SUCCESS_FAIL = 0
    SUCCESS_CORE = 1
    SUCCESS_RESOURCES = 2
    SUCCESS_CONTROL = 4

    attr_accessor :world

    def initialize
      @world = World.new
    end

    def cmdNetGetForAttack(target_id)
      net = @world.get_net(target_id)
      return net
    end

    def cmdNetLeave(target_id)
      @world.leave_net(target_id)
    end

    def cmd(command, options = {})
      case command
      when 'NetGetForAttack'
        cmdNetGetForAttack(options[:target_id])
      end
    end

    def cmdFightUpdate(target_id, options)
      # Implementación para actualizar la lucha
    end

    def cmdFight(target_id, options)
      # Implementación para luchar
    end

    def config
      { 'version' => '1.0' }
    end

    def app_settings
      { 'node types' => ['type1', 'type2'], 'program types' => ['type1', 'type2'] }
    end
  end
end

class World
  def get_net(target_id)
    { profile: { money: 100, bitcoins: 10 } }
  end

  def leave_net(target_id)
    true
  end

  def load
    true
  end

  def targets
    [Target.new(1, 'Target 1'), Target.new(2, 'Target 2')]
  end

  def new
    targets
  end
end

class Target
  attr_accessor :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end
end

class Logger
  def log(message)
    puts message
  end

  def error(message)
    puts "Error: #{message}"
  end
end

class Autohack < Sandbox::Script
  BLACKLIST = [127]
  TIMEOUT = 300

  def initialize
    @logger = Logger.new
    @start_time = Time.now
    @game = Hackers::Game.new
  end

  def main
    if @args[0].nil?
      @logger.log('Specify the number of hosts')
      return
    end

    unless @game.connected?
      @logger.log('Not connected')
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
        next if target.nil?

        @logger.log("Attacking target ID: #{k}")
        @logger.log("Attack #{k} / #{target.name}")

        begin
          net = @game.cmd('NetGetForAttack', target_id: k)
          @logger.log("Got net for attack")
          sleep(rand(4..9))

          update = @game.cmdFightUpdate(k, {
            money: 0,
            bitcoin: 0,
            nodes: '',
            loots: '',
            success: Hackers::Game::SUCCESS_FAIL,
            programs: ''
          })
          @logger.log("Updated fight")
          sleep(rand(35..95))

          version = [
            @game.config['version'],
            @game.app_settings['node types'].join(','),
            @game.app_settings['program types'].join(','),
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
      puts "Error:#{e.message}
    end
  end
end