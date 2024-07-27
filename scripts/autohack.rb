class Autohack < Sandbox::Script
  BLACKLIST = [127]

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

    targets.each do |target|
      k = target_id
      @logger.log("Target ID: #{k}")

      next if BLACKLIST.include?(k)

      # Obtener el nombre del jugador
      player_name = @game.player.name(k)
      @logger.log("Target Name: #{player_name}")

      # Atacar al jugador
      attack_target(k, player_name)
    end
  end

  def attack_target(target_id, player_name)
    @logger.log("Attacking target ID: #{target_id} - #{player_name}")

    begin
      # Intentar obtener la red para atacar
      net = @game.cmdNetGetForAttack(target_id)
      @logger.log("Got net for attack: #{net.inspect}")

      # Actualizar la lucha
      update = @game.cmdFightUpdate(target_id, { 
        money: 0, 
        bitcoin: 0, 
        nodes: '', 
        loots: '', 
        success: Hackers::Game::SUCCESS_FAIL, 
        programs: '' 
      } )
      @logger.log("Updated fight: #{update.inspect}")

      # Luchar
      version = [ 
        @game.config['version'], 
        @game.app_settings.get('node types'), 
        @game.app_settings.get('program types'), 
      ].join(',')
      @logger.log("Version: #{version}")

      success = Hackers::Game::SUCCESS_CORE | Hackers::Game::SUCCESS_RESOURCES | Hackers::Game::SUCCESS_CONTROL
      fight = @game.cmdFight(target_id, { 
        money: net['profile'].money, 
        bitcoin: net['profile'].bitcoins, 
        nodes: '', 
        loots: '', 
        success: success, 
        programs: '', 
        summary: '', 
        version: version, 
        replay: '' 
      } )
      @logger.log("Fought: #{fight.inspect}")

      # Dejar la red
      leave = @game.cmdNetLeave(target_id)
      @logger.log("Left network: #{leave.inspect}")

      @game.player.load
    rescue => e
      @logger.error(e)
      @logger.log("Error attacking target ID: #{target_id} - #{player_name}")
      sleep(rand(165..295))
    end
  end
end 