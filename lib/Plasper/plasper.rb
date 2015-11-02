module Plasper
  class Plasper
    attr_reader :weights

    def initialize
      @selectors = { count: {}, first: {}, next: {}, last: {} }
      @weights   = { count: {}, first: {}, next: {}, last: {} }
    end

    def word
      letter_count = weighted :count, :letter
      if letter_count == 1
        last_letter! nil
      elsif letter_count > 0
        result = first_letter
        (letter_count - 2).times { result += next_letter!(result[-1]) }
        result + last_letter!(result[-1])
      end
    end

    def sentence
      string = weighted(:count, :word).to_i.times.map { word }.join(' ')
      string[0] = Unicode.upcase(string[0]) unless string.to_s == ''
      string
    end

    def passage
      weighted(:count, :sentence).to_i.times.map { sentence }.join('. ')
    end

    def first_letter
      weighted(:first, :letter).to_i
    end

    def next_letter(current_letter)
      weighted :next, current_letter
    end

    def next_letter!(current_letter)
      next_letter(current_letter) || first_letter.to_s
    end

    def last_letter(penultimate_letter)
      weighted :last, penultimate_letter
    end

    def last_letter!(penultimate_letter)
      last_letter(penultimate_letter) || next_letter!(penultimate_letter)
    end

    # @param [String] word
    def add_word(word)
      add_weight :count, :letter, word.length
      add_weight :first, :letter, word[0]
      (word.length - 1).times { |l| add_weight :next, word[l], word[l.succ] }
      add_weight :last, word[-2], word[-1]
    end

    def add_sentence(sentence)
      words = sentence.split(/\s+/)
      add_weight :count, :word, words.length
      words.each do |word|
        stripped_word = word.gsub(/[^[:word:]-]/u, '')
        add_word Unicode.downcase(stripped_word) unless stripped_word == ''
      end
    end

    def add_passage(passage)
      sentences = passage.split(/[?!.]/).select { |sentence| sentence.chomp != '' }
      sentences.each { |sentence| add_sentence sentence }
      add_weight :count, :sentence, sentences.count
    end

    def add_weight(type, group, item, weight = 1)
      @weights[type][group] ||= Hash.new(0)

      @weights[type][group][item] += Integer weight
    end

    private

    def weighted(type, group)
      if @weights[type].has_key?(group)
        @selectors[type][group] ||= WeightedSelect::Selector.new @weights[type][group]
        @selectors[type][group].select
      end
    end
  end
end
