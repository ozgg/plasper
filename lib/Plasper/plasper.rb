module Plasper
  class Plasper
    attr_reader :weights, :letters

    def initialize
      @selectors = { next: Hash.new, last: Hash.new }
      @weights   = {}
      @letters   = { next: Hash.new, last: Hash.new }
    end

    def word
      letter_count = weighted :flat, :letter_count
      if letter_count == 1
        last_letter! nil
      elsif letter_count > 0
        result = first_letter
        (letter_count - 2).times { result += next_letter!(result[-1]) }
        result + last_letter!(result[-1])
      end
    end

    def sentence
      string = weighted(:flat, :word_count).to_i.times.map { word }.join(' ')
      string[0] = Unicode.upcase(string[0]) unless string.to_s == ''
      string
    end

    def passage
      weighted(:flat, :sentence_count).to_i.times.map { sentence }.join('. ')
    end

    def first_letter
      weighted :flat, :first_letter
    end

    def next_letter(current_letter)
      weighted_letter :next, current_letter
    end

    def next_letter!(current_letter)
      next_letter(current_letter) || first_letter.to_s
    end

    def last_letter(penultimate_letter)
      weighted_letter :last, penultimate_letter
    end

    def last_letter!(penultimate_letter)
      last_letter(penultimate_letter) || next_letter!(penultimate_letter)
    end

    # @param [String] word
    def add_word(word)
      add_weight :flat, :letter_count, word.length
      add_weight :flat, :first_letter, word[0]
      (word.length - 1).times { |l| add_letter :next, word[l], word[l.succ] }
      add_letter :last, word[-2], word[-1]
    end

    def add_sentence(sentence)
      words = sentence.split(/\s+/)
      add_weight :flat, :word_count, words.length
      words.each do |word|
        stripped_word = word.gsub(/[^[:word:]-]/u, '')
        add_word Unicode.downcase(stripped_word) unless stripped_word == ''
      end
    end

    def add_passage(passage)
      sentences = passage.split(/[?!.]/).select { |sentence| sentence.chomp != '' }
      sentences.each { |sentence| add_sentence sentence }
      add_weight :flat, :sentence_count, sentences.count
    end

    def add_weight(outer, inner, item, weight = 1)
      @weights[outer] ||= Hash.new
      @weights[outer][inner] ||= Hash.new(0)
      @weights[outer][inner][item] += Integer weight
    end

    def add_letter(category, letter, adjacent_letter, weight = 1)
      @letters[category][letter] ||= Hash.new(0)

      @letters[category][letter][adjacent_letter] += Integer weight
    end

    private

    def weighted(outer, inner)
      if @weights.has_key?(outer) && @weights[outer].has_key?(inner)
        @selectors[outer] ||= Hash.new
        @selectors[outer][inner] ||= WeightedSelect::Selector.new @weights[outer][inner]
        @selectors[outer][inner].select
      end
    end

    def weighted_letter(category, letter)
      if @letters[category].has_key? letter
        @selectors[category][letter] = WeightedSelect::Selector.new @letters[category][letter]
        @selectors[category][letter].select
      end
    end
  end
end
