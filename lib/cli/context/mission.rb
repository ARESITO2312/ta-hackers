# frozen_string_literal: true

## Commands

# list
CONTEXT_MISSION.add_command(
  :list,
  description: 'Show missions log'
) do |tokens, shell|
  if GAME.sid.empty?
    shell.puts('No session ID')
    next
  end

  msg = 'Missions get log'
  missions = GAME.cmdPlayerMissionsGetLog
  LOGGER.log(msg)

  shell.puts("\e[1;35m\u2022 Missions log\e[0m")
  shell.puts(
    format(
      "  \e[35m%-1s %-7s %-7s %-8s %-20s\e[0m",
      '',
      'ID',
      'Money',
      'Bitcoins',
      'Datetime'
    )
  )

  missions.each do |k, v|
    status = String.new
    case v['finished']
    when Hackers::Game::MISSION_AWAITS
      status = "\e[37m\u2690\e[0m" 
    when Hackers::Game::MISSION_FINISHED
      status = "\e[32m\u2691\e[0m"
    when Hackers::Game::MISSION_REJECTED
      status = "\e[31m\u2691\e[0m"
    end

    shell.puts(
      format(
        '  %-1s %-7d %-7d %-8d %-20s',
        status,
        k,
        v['money'],
        v['bitcoins'],
        v['datetime']
      )
    )
  end
rescue Hackers::RequestError => e
  LOGGER.error("#{msg} (#{e})")
end

# start
CONTEXT_MISSION.add_command(
  :start,
  description: 'Start mission',
  params: ['<id>']
) do |tokens, shell|
  if GAME.sid.empty?
    shell.puts('No session ID')
    next
  end

  id = tokens[1].to_i

  unless GAME.missions_list.exist?(id)
    shell.puts('No such mission')
    next
  end

  msg = 'Mission message delivered'
  GAME.cmdPlayerMissionMessageDelivered(id)
  LOGGER.log(msg)
rescue Hackers::RequestError => e
  LOGGER.error("#{msg} (#{e})")
end

# reject
CONTEXT_MISSION.add_command(
  :reject,
  description: 'Reject mission',
  params: ['<id>']
) do |tokens, shell|
  if GAME.sid.empty?
    shell.puts('No session ID')
    next
  end

  id = tokens[1].to_i
  unless GAME.missions_list.exist?(id)
    shell.puts('No such mission')
    next
  end

  msg = 'Mission reject'
  GAME.cmdPlayerMissionReject(id)
  LOGGER.log(msg)
rescue Hackers::RequestError => e
  LOGGER.error("#{msg} (#{e})")
end