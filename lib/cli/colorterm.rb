# frozen_string_literal: true

module ColorTerm
  RESET = "\e[0m"

  # Colores básicos
  BLACK   = "\e[30m"
  RED     = "\e[31m"
  GREEN   = "\e[32m"
  YELLOW  = "\e[33m"
  BLUE    = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN    = "\e[36m"
  BROWN   = "\e[33m"
  WHITE   = "\e[37m"

  def self.black;   BLACK;   end
  def self.red;     RED;     end
  def self.green;   GREEN;   end
  def self.yellow;  YELLOW;  end
  def self.blue;    BLUE;    end
  def self.magenta; MAGENTA; end
  def self.cyan;    CYAN;    end
  def self.brown;   BROWN;   end
  def self.white;   WHITE;   end
  def self.reset;   RESET;   end

  # Clase para estilos
  class ColorString < String
    def bold;      "\e[1m#{self}"; end
    def underline; "\e[4m#{self}"; end
    def blink;     "\e[5m#{self}"; end
  end

  # Métodos que devuelven la cadena con estilo
  class << self
    def black_bold;   ColorString.new(BLACK).bold;   end
    def red_bold;     ColorString.new(RED).bold;     end
    def green_bold;   ColorString.new(GREEN).bold;   end
    def yellow_bold;  ColorString.new(YELLOW).bold;  end
    def blue_bold;    ColorString.new(BLUE).bold;    end
    def magenta_bold; ColorString.new(MAGENTA).bold; end
    def cyan_bold;    ColorString.new(CYAN).bold;    end
    def brown_bold;   ColorString.new(BROWN).bold;   end
    def white_bold;   ColorString.new(WHITE).bold;   end
  end
end
