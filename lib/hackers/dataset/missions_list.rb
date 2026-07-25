# frozen_string_literal: true

module Hackers
  ##
  # Missions list
  class MissionsList < Dataset
    include Enumerable

    Mission = Struct.new(
      :id,
      :giver_name,
      :name,
      :message_info,
      :goals,
      :x,
      :y,
      :country,
      :required_missions,
      :required_core_level,
      :reward_money,
      :reward_bitcoins,
      :message_completion,
      :message_news,
      :topology,
      :nodes,
      :additional_money,
      :additional_bitcoins,
      :group
    )

    def initialize(*)
      super
      @missions = []
    end

    def load
      @raw_data = @api.missions_list
      parse
    end

    def exist?(mission)
      @missions.any? { |m| m.id == mission }
    end

    def get(mission)
      @missions.detect { |m| m.id == mission }
    end

    def each(&block)
      @missions.each(&block)
    end

    private

    def parse
      data = Serializer.parseData(@raw_data)
      @missions.clear

      # Solo procesa si hay datos válidos
      return unless data && data[0]

      data[0].each do |record|
        # Valor por defecto vacío si no existe el campo
        goals = record[4] ? Serializer.normalizeData(record[4]).split(',') : []
        req_missions = record[9] ? Serializer.normalizeData(record[9]).split(',') : []

        @missions << Mission.new(
          record[0]&.to_i || 0,
          record[1],
          Serializer.normalizeData(record[2]),
          record[3],
          goals,
          record[5]&.to_i || 0,
          record[6]&.to_i || 0,
          record[7]&.to_i || 0,
          req_missions,
          record[12]&.to_i || 0,
          record[13]&.to_i || 0,
          record[14]&.to_i || 0,
          Serializer.normalizeData(record[17] || ''),
          Serializer.normalizeData(record[19] || ''),
          Serializer.normalizeData(record[21] || ''),
          Serializer.normalizeData(record[22] || ''),
          record[24]&.to_i || 0,
          record[25]&.to_i || 0,
          record[28]
        )
      end
    end
  end
end
