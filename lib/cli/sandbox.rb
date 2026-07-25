# frozen_string_literal: true

require 'json'
# ✅ Solo cambiamos la ruta de carga
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
                  :log_prefix, :error_prefix, :info_prefix

    def initialize(shell)
      @shell = shell
      @reading = false
      @log_cterm = ColorTerm.white
      @error_cterm = ColorTerm.white
      @info_cterm = ColorTerm.white
      @log_prefix_cterm = ColorTerm.white
      @error_prefix_cterm = ColorTerm.white
      @info_prefix_cterm = ColorTerm.white
      @log_prefix = String.new
      @error_prefix = String.new
      @info_prefix = String.new
    end

    def log(message)
      @shell.puts(@log_prefix_cterm.get(@log_prefix) + @log_cterm.get(message.to_s))
      # ✅ Protección contra el error de refresh_line
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
      # ✅ Misma protección
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
      # ✅ Misma protección
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
