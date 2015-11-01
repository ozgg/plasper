module Plasper
  class Plasper
    attr_reader :length_weight, :letter_weight, :first_weight, :next_weight, :word_count

    def add_letter_weight(letter, weight = 1)
      @letter_weight ||= Hash.new(0)

      @letter_weight[letter] += Integer weight
    end

    def add_length_weight(length, weight = 1)
      @length_weight ||= Hash.new(0)

      @length_weight[length] += Integer weight
    end

    def add_first_weight(letter, weight = 1)
      @first_weight ||= Hash.new(0)

      @first_weight[letter] += Integer weight
    end

    def add_next_weight(letter, next_letter, weight = 1)
      @next_weight ||= Hash.new
      @next_weight[letter] = Hash.new(0) unless @next_weight.has_key? letter

      @next_weight[letter][next_letter] += Integer weight
    end

    # @param [String] word
    def add_word(word)
      add_length_weight word.length
      word.each_char { |letter| add_letter_weight letter }
      add_first_weight word[0]
      word.length.times { |l| add_next_weight word[l], word[l.succ] }
    end

    def add_sentence(sentence)
      @word_count ||= Hash.new(0)
      words       = sentence.split(/\s+/)

      @word_count[words.length] += 1
    end
  end
end
