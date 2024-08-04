# frozen_string_literal: true

module Hackers
  ## 
  # Skin types
  class SkinTypes < Dataset
    include Enumerable

    Skin = Struct.new(:id, :name, :price, :rank)

    def initialize(*)
      super
      @skins = []
    end

    def load
      @raw_data = @api.skin_types
      parse
    end

    def exist?(skin)
      @skins.any? { |s| (skin.id) == skin }
    end

    def get(skin)
      @skins.detect { |s| (skin.id) == skin }
    end

    def each(&block)
      @skins.each(&block)
    end

    private

    def parse
      data = Serializer.parseData(@raw_data)
      @skins.clear
      data[0].each do |record|
        # Establece el precio y el rango en 0
        @skins << Skin.new(
          record[0].to_i,
          record[1],
          0, # Precio
          0  # Rango
        )
      end
    end
  end
end