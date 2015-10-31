module Plasper
  class Plasper
    attr_reader :length_weight, :letter_weight, :first_letters, :next_letters

    def initialize
      @length_weight = Hash.new(0)
      @letter_weight = Hash.new(0)
      @first_letters = Hash.new(0)
      @next_letters  = Hash.new
    end

    # @param [String] word
    def add_word(word)
      @length_weight[word.length] += 1
      word.each_char { |letter| @letter_weight[letter] += 1 }
      @first_letters[word[0]] += 1
      count_next_letters word
    end

    private

    # @param [String] word
    def count_next_letters(word)
      word.length.times do |l|
        letter = word[l]
        @next_letters[letter] = Hash.new(0) unless @next_letters.has_key? letter
        @next_letters[letter][word[l.succ]] += 1
      end
    end
  end
end
