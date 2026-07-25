# frozen_string_literal: true

module Hackers
  ##
  # Language translations
  class LanguageTranslations < Dataset
    include Enumerable

    def initialize(*)
      super

      @translations = {}
    end

    def load
      @raw_data = @api.language_translations
      parse
    end

    def get(key)
      @translations[key]
    end

    def each(&block)
      @translations.keys.each(&block)
    end

    private

    def parse
  data = Serializer.parseData(@raw_data)
  # Solo si existen datos, los recorre
  if data.is_a?(Array) && !data.empty? && data[0].is_a?(Array)
    data[0].each do |record|
      @translations[record[0]] = record[1]
    end
  else
    # Si no hay datos, usa un arreglo vacío y no se cae
    puts "⚠️ No se cargaron traducciones, usando valores por defecto"
  end
end
end