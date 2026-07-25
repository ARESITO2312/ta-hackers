# frozen_string_literal: true

require 'io/console'
require 'rbconfig'

# ✅ ESTA CLASE FALTABA O SE ROMPIÓ
module Sandbox
  class Config
    def initialize(file)
      @file = file
      @data = {}
      load if File.exist?(@file)
    end

    def [](key)
      @data[key.to_s]
    end

    def []=(key, value)
      @data[key.to_s] = value
    end

    def load
      return unless File.exist?(@file)
      File.readlines(@file).each do |line|
        line.strip!
        next if line.empty? || line.start_with?('#')
        k, v = line.split('=', 2)
        next unless k && v
        @data[k.strip] = v.strip
      end
    end

    def save
      File.write(@file, @data.map { |k,v| "#{k}=#{v}" }.join("\n"))
    end
  end

  class Logger
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
      # ✅ PROTECCIÓN DEFINITIVA
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
      # ✅ MISMA PROTECCIÓN
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
      # ✅ MISMA PROTECCIÓN
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

  class Shell
    def initialize(input = $stdin, output = $stdout)
      @input = input
      @output = output
      @reading = false
    end

    def puts(*args)
      args.each { |line| @output.puts(line) }
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
end
