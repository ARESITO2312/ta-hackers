# frozen_string_literal: true

module ColorTerm
  RESET = "\e[0m"

  def self.black;   "\e[30m"; end
  def self.red;     "\e[31m"; end
  def self.green;   "\e[32m"; end
  def self.yellow;  "\e[33m"; end
  def self.blue;    "\e[34m"; end
  def self.magenta; "\e[35m"; end
  def self.cyan;    "\e[36m"; end
  def self.brown;   "\e[33m"; end
  def self.white;   "\e[37m"; end

  def self.reset; RESET; end

  class << self
    %i[black red green yellow blue magenta cyan brown white].each do |c|
      define_method(c) do
        ColorString.new(send(c.to_s))
      end
    end
  end

  class ColorString < String
    def bold;      "\e[1m#{self}"; end
    def underline; "\e[4m#{self}"; end
    def blink;     "\e[5m#{self}"; end
  end
end
