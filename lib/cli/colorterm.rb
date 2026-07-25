  class Logger
    # ✅ TODOS LOS ATRIBUTOS EXACTOS QUE USA EL PROGRAMA
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
