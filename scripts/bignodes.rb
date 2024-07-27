class BigNodes < Sandbox::Script
  def main
    size = @args[0]
    if size.nil? || size !~ /^\d+$/
      @logger.log("Specify a size argument")
      return
    end

    begin
      net = @game.cmdNetGetForMaint
    rescue Trickster::Hackers::RequestError => e
      @logger.error("#{e}")
      return
    end

    net["net"].each_index do |i|
      net["net"][i]["size"] = size.to_i
    end

    begin
      @game.cmdUpdateNet(net["net"])
    rescue Trickster::Hackers::RequestError => e
      @logger.error("#{e}")
      return
    end

    @logger.log("Nodes size updated to #{size}")
  end
end