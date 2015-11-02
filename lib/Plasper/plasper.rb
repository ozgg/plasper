module Plasper
  class Plasper
    attr_reader :weights, :letters

    def initialize
      @selectors = { next: Hash.new, last: Hash.new }
      @weights   = Hash.new
      @letters   = { next: Hash.new, last: Hash.new }
    end

    def word
      letter_count = weighted :letter_count
      if letter_count == 1
        last_letter! nil
      elsif letter_count > 0
        result = first_letter
        (letter_count - 2).times { result += next_letter!(result[-1]) }
        result + last_letter!(result[-1])
      end
    end

    def sentence
      string = weighted(:word_count).to_i.times.map { word }.join(' ')
      string[0] = Unicode.upcase(string[0]) unless string.to_s == ''
      string
    end

    def passage
      weighted(:sentence_count).to_i.times.map { sentence }.join('. ')
    end

    def first_letter
      weighted :first_letter
    end

    def next_letter(current_letter)
      if @letters[:next].has_key?(current_letter)
        @selectors[:next][current_letter] ||= WeightedSelect::Selector.new @letters[:next][current_letter]
        @selectors[:next][current_letter].select
      end
    end

    def next_letter!(current_letter)
      next_letter(current_letter) || first_letter.to_s
    end

    def last_letter(penultimate_letter)
      if @letters[:last].has_key?(penultimate_letter)
        @selectors[:last][penultimate_letter] ||= WeightedSelect::Selector.new @letters[:last][penultimate_letter]
        @selectors[:last][penultimate_letter].select
      end
    end

    def last_letter!(penultimate_letter)
      last_letter(penultimate_letter) || next_letter!(penultimate_letter)
    end

    # @param [String] word
    def add_word(word)
      add_weight :letter_count, word.length
      add_weight :first_letter, word[0]
      (word.length - 1).times { |l| add_letter :next, word[l], word[l.succ] }
      add_letter :last, word[-2], word[-1]
    end

    def add_sentence(sentence)
      words = sentence.split(/\s+/)
      add_weight :word_count, words.length
      words.each do |word|
        stripped_word = word.gsub(/[^[:word:]-]/u, '')
        add_word Unicode.downcase(stripped_word) unless stripped_word == ''
      end
    end

    def add_passage(passage)
      sentences = passage.split(/[?!.]/).select { |sentence| sentence.chomp != '' }
      sentences.each { |sentence| add_sentence sentence }
      add_weight :sentence_count, sentences.count
    end

    def add_weight(category, item, weight = 1)
      @weights[category] ||= Hash.new(0)

      @weights[category][item] += Integer weight
    end

    def add_letter(category, letter, adjacent_letter, weight = 1)
      @letters[category][letter] ||= Hash.new(0)

      @letters[category][letter][adjacent_letter] += Integer weight
    end

    private

    def weighted(category)
      if @weights.has_key? category
        @selectors[category] ||= WeightedSelect::Selector.new @weights[category]
        @selectors[category].select
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
