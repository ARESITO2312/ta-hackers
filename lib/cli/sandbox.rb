# frozen_string_literal: true

require 'io/console'

class Sandbox::Logger
  attr_accessor :logPrefix, :logPrefixCterm, :logCterm
  attr_accessor :errorPrefix, :errorPrefixCterm, :errorCterm
  attr_accessor :infoPrefix, :infoPrefixCterm, :infoCterm

  def initialize(shell)
    @shell = shell
  end

  def log(message)
    line = +""
    line << "#{logPrefixCterm}#{logPrefix}#{ColorTerm.reset}#{logCterm}#{message}#{ColorTerm.reset}"
    @shell.puts(line)
    # ✅ PROTECCIÓN DEFINITIVA AQUÍ
    begin
      if defined?(Readline)&.respond_to?(:refresh_line)
        Readline.refresh_line if @reading
      elsif defined?(Reline)&.respond_to?(:refresh_line)
        Reline.refresh_line if @reading
      end
    rescue StandardError
      nil
    end
  end

  def error(message)
    line = +""
    line << "#{errorPrefixCterm}#{errorPrefix}#{ColorTerm.reset}#{errorCterm}#{message}#{ColorTerm.reset}"
    @shell.puts(line)
    # ✅ MISMA PROTECCIÓN AQUÍ
    begin
      if defined?(Readline)&.respond_to?(:refresh_line)
        Readline.refresh_line if @reading
      elsif defined?(Reline)&.respond_to?(:refresh_line)
        Reline.refresh_line if @reading
      end
    rescue StandardError
      nil
    end
  end

  def info(message)
    line = +""
    line << "#{infoPrefixCterm}#{infoPrefix}#{ColorTerm.reset}#{infoCterm}#{message}#{ColorTerm.reset}"
    @shell.puts(line)
    # ✅ MISMA PROTECCIÓN AQUÍ
    begin
      if defined?(Readline)&.respond_to?(:refresh_line)
        Readline.refresh_line if @reading
      elsif defined?(Reline)&.respond_to?(:refresh_line)
        Reline.refresh_line if @reading
      end
    rescue StandardError
      nil
    end
  end
end

class Sandbox::Shell
  def initialize(input = $stdin, output = $stdout)
    @input = input
    @output = output
    @reading = false
  end

  def puts(*args)
    args.each do |line|
      @output.puts(line)
    end
  end

  def print(*args)
    @output.print(*args)
  end

  def readline(prompt = "", add_history = false)
    @reading = true
    line = Readline.readline(prompt, add_history)
    @reading = false
    line
  end
end
