# frozen_string_literal: true

module Hackers
  ##
  # Chat messages
  class Chat < Dataset
    include Enumerable

    Message = Struct.new(:datetime, :name, :message, :id, :experience, :rank, :country)

    def initialize(*)
      super
      @messages = []
    end

    def load
      @raw_data = @api.chat
      parse
    end

    def each(&block)
      @messages.each(&block)
    end

    private

    def parse
      data = Serializer.parseData(@raw_data)
      return unless data && data[0]

      @messages = data[0].reverse_each.map do |record|
        Message.new(
          record[0],
          record[1],
          Serializer.normalizeData(record[2] || ''),
          record[3]&.to_i || 0,
          record[4]&.to_i || 0,
          record[5]&.to_i || 0,
          record[6]&.to_i || 0
        )
      rescue StandardError
        next
      end.compact
    end
  end
end
