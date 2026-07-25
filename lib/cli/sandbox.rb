# frozen_string_literal: true

require 'json'
require_relative 'colorterm'

module Sandbox
  ##
  # Config
  class Config < Hash
    attr_accessor :file

    def initialize(file)
      super
      @file = file
    end

    def load
      data = JSON.parse(File.read(@file))
      return unless data.instance_of?(Hash)
      merge!(data)
    end

    def save
      File.write(@file, JSON.pretty_generate(self))
    end
  end

  ##
  # Logger
  class Logger
    attr_accessor :log_cterm, :error_cterm, :info_cterm,
                  :log_prefix_cterm, :error_prefix_cterm, :info_prefix_cterm,
                  :log_prefix, :error_prefix, :info_prefix,
                  :logSuffix, :errorSuffix, :infoSuffix,
                  :logPrefix, :errorPrefix, :infoPrefix,
                  :logPrefixCterm, :errorPrefixCterm, :infoPrefixCterm

    def initialize(shell)
      @shell = shell
      @reading = false
      # Valores originales
      @log_cterm = ColorTerm.white
      @error_cterm = ColorTerm.white
      @info_cterm = ColorTerm.white
      @log_prefix_cterm = ColorTerm.white
      @error_prefix_cterm = ColorTerm.white
      @info_prefix_cterm = ColorTerm.white
      @log_prefix = String.new
      @error_prefix = String.new
      @info_prefix = String.new
      # Sincronizamos todos los nombres que usa el programa
      @logPrefix = @log_prefix
      @errorPrefix = @error_prefix
      @infoPrefix = @info_prefix
      @logPrefixCterm = @log_prefix_cterm
      @errorPrefixCterm = @error_prefix_cterm
      @infoPrefixCterm = @info_prefix_cterm
      @logSuffix = String.new
      @errorSuffix = String.new
      @infoSuffix = String.new
    end

    def log(message)
      @shell.puts(@log_prefix_cterm.get(@log_prefix) + @log_cterm.get(message.to_s))
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
      @shell.puts(@error_prefix_cterm.get(@error_prefix) + @error_cterm.get(message.to_s))
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
      @shell.puts(@info_prefix_cterm.get(@info_prefix) + @info_cterm.get(message.to_s))
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

  ##
  # Parent class for scripts
  class Script
    def initialize(game, shell, logger, args)
      @game = game
      @shell = shell
      @logger = logger
      @args = args
    end

    def main; end
    def finish; end
  end
end
