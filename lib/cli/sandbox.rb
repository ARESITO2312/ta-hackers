# frozen_string_literal: true

require 'io/console'
require 'rbconfig'
require_relative 'colorterm'

module Sandbox
  # Solo agregamos el método que falta a la clase que ya existe
  class Config
    def key?(key)
      @data&.key?(key.to_s) || false
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
