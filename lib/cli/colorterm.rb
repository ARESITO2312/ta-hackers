# frozen_string_literal: true

module ColorTerm
  RESET = "\e[0m"

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

  class ColorString < String
    def bold;      "\e[1m#{self}"; end
    def underline; "\e[4m#{self}"; end
    def blink;     "\e[5m#{self}"; end
  end
end
