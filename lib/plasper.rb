module Plasper
  class Plasper
    attr_reader :length_weight

    def initialize
      @length_weight = Hash.new(0)
    end

    def add_word(word)
      @length_weight[word.length] += 1
    end
  end
end
