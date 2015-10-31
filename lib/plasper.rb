module Plasper
  class Plasper
    attr_reader :length_weight, :letter_weight

    def initialize
      @length_weight = Hash.new(0)
      @letter_weight = Hash.new(0)
    end

    # @param [String] word
    def add_word(word)
      @length_weight[word.length] += 1
      word.each_char { |letter| @letter_weight[letter] += 1 }
    end

    private
  end
end
