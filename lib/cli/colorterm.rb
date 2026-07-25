# frozen_string_literal: true

# ✅ PRIMERO CARGAMOS LO QUE NECESITAMOS, ANTES DE USARLO
require 'io/console'
require 'rbconfig'
require_relative 'colorterm'

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

    def key?(key)
      @data.key?(key.to_s)
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
    attr_accessor :logPrefix, :logPrefixCterm, :logCterm, :logSuffix
    attr_accessor :errorPrefix, :errorPrefixCterm, :errorCterm, :errorSuffix
    attr_accessor :infoPrefix, :infoPrefixCterm, :infoCterm, :infoSuffix

    def initialize(shell)
      @shell = shell
    end

    def log(message)
      line = +""
      line << "#{logPrefixCterm}#{logPrefix}#{ColorTerm.reset}#{logCterm}#{message}#{ColorTerm.reset}#{logSuffix}"
      @shell.puts(line)
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
      line << "#{errorPrefixCterm}#{errorPrefix}#{ColorTerm.reset}#{errorCterm}#{message}#{ColorTerm.reset}#{errorSuffix}"
      @shell.puts(line)
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
      line << "#{infoPrefixCterm}#{infoPrefix}#{ColorTerm.reset}#{infoCterm}#{message}#{ColorTerm.reset}#{infoSuffix}"
      @shell.puts(line)
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
