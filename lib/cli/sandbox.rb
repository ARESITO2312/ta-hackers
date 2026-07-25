  class Config
    def initialize(file = nil)
      @file = file
      @data = {}
      load if @file && File.exist?(@file)
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
      return unless @file && File.exist?(@file)
      File.readlines(@file).each do |line|
        line.strip!
        next if line.empty? || line.start_with?('#')
        k, v = line.split('=', 2)
        next unless k && v
        @data[k.strip] = v.strip
      end
    end

    def save
      return unless @file
      File.write(@file, @data.map { |k,v| "#{k}=#{v}" }.join("\n"))
    end
  end
