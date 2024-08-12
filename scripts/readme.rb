class Readme < Sandbox::Script
  def main
    if @args[0].nil?
      @logger.log('Specify player ID')
      return
    end

    id = @args[0].to_i

    begin
      friend = @game.friend(id)
      friend.load_readme

      if @args[1].nil?
        # Modo lectura
        readme = friend.readme
        if readme.empty?
          @logger.log('Readme is empty')
          return
        end

        readme.each do |message|
          @logger.log(message)
        end
      else
        # Modo escritura
        message = @args[1]
        @game.player.readme.write(message)
        @game.player.readme.update
        @logger.log("Mensaje escrito en el readme del jugador #{id}: #{message}")
      end
    rescue Hackers::RequestError => e
      @logger.error(e)
    end
  end
end