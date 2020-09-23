module Sandbox
  class ContextRoot < ContextBase
    def initialize(game, shell)
      super(game, shell)
      @commands.merge!({
                         "query" => ["[query]", "Analyze queries and data dumps"],
                         "net" => ["[net]", "Network"],
                         "world" => ["[world]", "World"],
                         "script" => ["[script]", "Scripts"],
                         "chat" => ["[chat]", "Internal chat"],
                         "connect" => ["connect", "Connect to the server"],
                         "trans" => ["trans", "Language translations"],
                         "settings" => ["settings", "Application settings"],
                         "nodes" => ["nodes", "Node types"],
                         "progs" => ["progs", "Program types"],
                         "missions" => ["missions", "Missions list"],
                         "skins" => ["skins", "Skin types"],
                         "news" => ["news", "News"],
                         "hints" => ["hints", "Hints list"],
                         "experience" => ["experience", "Experience list"],
                         "builders" => ["builders", "Builders list"],
                         "goals" => ["goals", "Goals types"],
                         "shields" => ["shields", "Shield types"],
                         "ranks" => ["ranks", "Rank list"],
                         "countries" => ["countries", "Contries list"],
                         "new" => ["new", "Create new account"],
                         "rename" => ["rename <name>", "Set new name"],
                         "info" => ["info <id>", "Get player info"],
                         "detail" => ["detail <id>", "Get detail player network"],
                         "hq" => ["hq <x> <y> <country>", "Set player HQ"],
                         "skin" => ["skin <skin>", "Set player skin"],
                         "top" => ["top <country>", "Show top ranking"],
                         "cpgen" => ["cpgen", "Cp generate code"],
                         "cpuse" => ["cpuse <code>", "Cp use code"],
                       })
    end
    
    def exec(words)
      cmd = words[0].downcase
      case cmd

      when "query", "net", "world", "script", "chat"
        @shell.context = "/#{cmd}"
        return

      when "trans"
        if @game.transLang.empty?
          @shell.puts "#{cmd}: No language translations"
          return
        end

        @shell.puts "Language translations:"
        @game.transLang.each do |k, v|
          @shell.puts " %-32s .. %s" % [k, v]
        end
        return
        
      when "settings"
        if @game.appSettings.empty?
          @shell.puts "#{cmd}: No application settings"
          return
        end

        @shell.puts "Application settings:"
        @game.appSettings.each do |k, v|
          @shell.puts " %-32s .. %s" % [k, v]
        end
        return

      when "nodes"
        if @game.nodeTypes.empty?
          @shell.puts "#{cmd}: No node types"
          return
        end

        @shell.puts "Node types:"
        @game.nodeTypes.each do |k, v|
          @shell.puts " %-2s .. %s" % [k, v["name"]]
        end
        return

      when "progs"
        if @game.programTypes.empty?
          @shell.puts "#{cmd}: No program types"
          return
        end

        @shell.puts "Program types:"
        @game.programTypes.each do |k, v|
          @shell.puts " %-2s .. %s" % [k, v["name"]]
        end
        return

      when "missions"
        if @game.missionsList.empty?
          @shell.puts "#{cmd}: No missions list"
          return
        end

        @shell.puts "Missions list:"
        @game.missionsList.each do |k, v|
          @shell.puts " %-7s .. %s, %s, %s" % [
                        k,
                        v["name"],
                        v["target"],
                        v["goal"],
                      ]
        end
        return

      when "skins"
        if @game.skinTypes.empty?
          @shell.puts "#{cmd}: No skin types"
          return
        end

        @shell.puts "Skin types:"
        @game.skinTypes.each do |k, v|
          @shell.puts " %-7d .. %s, %d, %d" % [
                        k,
                        v["name"],
                        v["price"],
                        v["rank"],
                      ]
        end
        return

      when "news"
        msg = "News"
        begin
          news = @game.cmdNewsGetList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        news.each do |k, v|
          @shell.puts "\e[34m%s \e[33m%s\e[0m" % [
                        v["date"],
                        v["title"],
                      ]
          @shell.puts "\e[35m%s\e[0m" % [
                        v["body"],
                      ]
          @shell.puts
        end
        return

      when "hints"
        if @game.hintsList.empty?
          @shell.puts "#{cmd}: No hints list"
          return
        end

        @game.hintsList.each do |k, v|
          @shell.puts " %-7d .. %s" % [
                        k,
                        v["description"],
                      ]
        end
        return

      when "experience"
        if @game.experienceList.empty?
          @shell.puts "#{cmd}: No experience list"
          return
        end

        @game.experienceList.each do |k, v|
          @shell.puts " %-7d .. %s" % [
                        k,
                        v["experience"],
                      ]
        end
        return

      when "builders"
        if @game.buildersList.empty?
          @shell.puts "#{cmd}: No builders list"
          return
        end

        @game.buildersList.each do |k, v|
          @shell.puts " %-7d .. %s" % [
                        k,
                        v["price"],
                      ]
        end
        return

      when "goals"
        if @game.goalsTypes.empty?
          @shell.puts "#{cmd}: No goals types"
          return
        end

        @game.goalsTypes.each do |k, v|
          @shell.puts " %-20s .. %d, %s, %s" % [
                        k,
                        v["amount"],
                        v["name"],
                        v["description"],
                      ]
        end
        return

      when "shields"
        if @game.shieldTypes.empty?
          @shell.puts "#{cmd}: No shield types"
          return
        end

        @game.shieldTypes.each do |k, v|
          @shell.puts " %-7d .. %d, %s, %s" % [
                        k,
                        v["price"],
                        v["name"],
                        v["description"],
                      ]
        end
        return

      when "ranks"
        if @game.rankList.empty?
          @shell.puts "#{cmd}: No rank list"
          return
        end

        @game.rankList.each do |k, v|
          @shell.puts " %-7d .. %d" % [
                        k,
                        v["rank"],
                      ]
        end
        return

      when "countries"
        if @game.countriesList.empty?
          @shell.puts "#{cmd}: No countries list"
          return
        end

        @game.countriesList.each do |k, v|
          @shell.puts " %-3d .. %s" % [
                        k,
                        v,
                      ]
        end
        return

      when "connect"
        msg = "Language translations"
        begin
          @game.transLang = @game.cmdTransLang
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)
 
        msg = "Application settings"
        begin
          @game.appSettings = @game.cmdAppSettings
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Node types and levels"
        begin
          @game.nodeTypes = @game.cmdGetNodeTypes
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Program types and levels"
        begin
          @game.programTypes = @game.cmdGetProgramTypes
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Missions list"
        begin
          @game.missionsList = @game.cmdGetMissionsList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Skin types"
        begin
          @game.skinTypes = @game.cmdSkinTypesGetList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)
        
        msg = "Hints list"
        begin
          @game.hintsList = @game.cmdHintsGetList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Experience list"
        begin
          @game.experienceList = @game.cmdGetExperienceList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Builders list"
        begin
          @game.buildersList = @game.cmdBuildersCountGetList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Goals types"
        begin
          @game.goalsTypes = @game.cmdGoalTypesGetList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Shield types"
        begin
          @game.shieldTypes = @game.cmdShieldTypesGetList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)
        
        msg = "Rank list"
        begin
          @game.rankList = @game.cmdRankGetList
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        msg = "Authenticate"
        begin
          auth = @game.cmdAuthIdPassword
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        @game.sid = auth["sid"]        
        return

      when "new"
        msg = "Player create"
        begin
          player = @game.cmdPlayerCreate
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        @shell.puts("\e[1;35m\u2022 New account\e[0m")
        @shell.puts("  ID: #{player["id"]}")
        @shell.puts("  Password: #{player["password"]}")
        @shell.puts("  Session ID: #{player["sid"]}")
        return

      when "rename"
        name = words[1]
        if name.nil?
          @shell.puts("#{cmd}: Specify name")
          return
        end

        msg = "Player set name"
        begin
          @game.cmdPlayerSetName(@game.config["id"], name)
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)
        return

      when "info"
        id = words[1]
        if id.nil?
          @shell.puts("#{cmd}: Specify ID")
          return
        end

        if @game.sid.empty?
          @shell.puts("#{cmd}: No session ID")
          return
        end
        
        msg = "Player get info"
        begin
          info = @game.cmdPlayerGetInfo(id)
          info["level"] = @game.getLevelByExp(info["experience"])
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        @shell.puts("\e[1;35m\u2022 Player info\e[0m")
        info.each do |k, v|
          @shell.puts("  %s: %s" % [k.capitalize, v])
        end
        return

      when "detail"
        id = words[1]
        if id.nil?
          @shell.puts("#{cmd}: Specify ID")
          return
        end

        if @game.sid.empty?
          @shell.puts("#{cmd}: No session ID")
          return
        end
        
        msg = "Get net details world"
        begin
          detail = @game.cmdGetNetDetailsWorld(id)
          detail["profile"]["level"] = @game.getLevelByExp(detail["profile"]["experience"])
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        @shell.puts("\e[1;35m\u2022 Detail player network\e[0m")
        detail["profile"].each do |k, v|
          @shell.puts("  %s: %s" % [k.capitalize, v])
        end
        @shell.puts
        @shell.puts(
          "  \e[35m%-12s %-4s %-5s %-12s %-12s\e[0m" % [
            "ID",
            "Type",
            "Level",
            "Time",
            "Name",
          ]
        )
        detail["nodes"].each do |k, v|
          @shell.puts(
            "  %-12d %-4d %-5d %-12d %-12s" % [
              k,
              v["type"],
              v["level"],
              v["time"],
              @game.nodeTypes[v["type"]]["name"],
            ]
          )
        end
        return

      when "hq"
        x = words[1]
        y = words[2]
        country = words[3]
        if x.nil? || y.nil? || country.nil?
          @shell.puts("#{cmd}: Specify x, y, country")
          return
        end

        if @game.sid.empty?
          @shell.puts("#{cmd}: No session ID")
          return
        end
        
        msg = "Set player HQ"
        begin
          @game.cmdSetPlayerHqCountry(@game.config["id"], x, y, country)
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)
        return

      when "skin"
        skin = words[1]
        if skin.nil?
          @shell.puts("#{cmd}: Specify skin")
          return
        end

        if @game.sid.empty?
          @shell.puts("#{cmd}: No session ID")
          return
        end
        
        msg = "Player set skin"
        begin
          response = @game.cmdPlayerSetSkin(skin)
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)
        return

      when "top"
        country = words[1]
        if country.nil?
          @shell.puts("#{cmd}: Specify country")
          return
        end

        if @game.sid.empty?
          @shell.puts("#{cmd}: No session ID")
          return
        end
        
        msg = "Ranking get all"
        begin
          top = @game.cmdRankingGetAll(country)
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        types = {
          "nearby" => "Players nearby",
          "country" => "Top country players",
          "world" => "Top world players",
        }

        types.each do |type, title|
          @shell.puts("\e[1;35m\u2022 #{title}\e[0m")
          @shell.puts(
            "  \e[35m%-12s %-25s %-12s %-7s %-12s\e[0m" % [
              "ID",
              "Name",
              "Experience",
              "Country",
              "Rank",
            ]
          )
          top[type].each do |player|
            @shell.puts(
              "  %-12s %-25s %-12s %-7s %-12s" % [
                player["id"],
                player["name"],
                player["experience"],
                player["country"],
                player["rank"],
              ]
            )
          end
          @shell.puts()
        end

        @shell.puts("\e[1;35m\u2022 Top countries\e[0m")
        @shell.puts(
          "  \e[35m%-7s %-12s\e[0m" % [
            "Country",
            "Rank",
          ]
        )
        top["countries"].each do |player|
          @shell.puts(
            "  %-7s %-12s" % [
              player["country"],
              player["rank"],
            ]
          )
        end
        return

      when "cpgen"
        if @game.sid.empty?
          @shell.puts("#{cmd}: No session ID")
          return
        end
        
        msg = "Cp generate code"
        begin
          code = @game.cmdCpGenerateCode(@game.config["id"], @game.config["platform"])
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        @shell.puts("\e[1;35m\u2022 Generated code\e[0m")
        @shell.puts("  Code: #{code}")
        return

      when "cpuse"
        code = words[1]
        if code.nil?
          @shell.puts("#{cmd}: Specify code")
          return
        end

        if @game.sid.empty?
          @shell.puts("#{cmd}: No session ID")
          return
        end
        
        msg = "Cp use code"
        begin
          data = @game.cmdCpUseCode(@game.config["id"], code, @game.config["platform"])
        rescue Trickster::Hackers::RequestError => e
          @shell.logger.error("#{msg} (#{e})")
          return
        end
        @shell.logger.log(msg)

        @shell.puts("\e[1;35m\u2022 Account credentials\e[0m")
        @shell.puts("  ID: #{data["id"]}")
        @shell.puts("  Password: #{data["password"]}")
        return
        
      end
      
      super(words)
    end
  end
end

