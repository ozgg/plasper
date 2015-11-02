module Plasper
  class Plasper
    attr_reader :next_weight, :last_weight
    attr_reader :words_weight, :sentences_weight
    attr_reader :weights

    def initialize
      @selectors = { next: Hash.new, last: Hash.new }
      @weights   = Hash.new
    end

    def word
      letter_count = word_length
      if letter_count == 1
        last_letter! nil
      elsif letter_count > 0
        result = first_letter
        (letter_count - 2).times { result += next_letter!(result[-1]) }
        result + last_letter!(result[-1])
      end
    end

    def sentence
      string = sentence_length.times.map { word }.join(' ')
      string[0] = Unicode.upcase(string[0]) unless string.to_s == ''
      string
    end

    def passage
      passage_length.times.map { sentence }.join('. ')
    end

    def first_letter
      if @weights.has_key? :first_letter
        @selectors[:first] ||= WeightedSelect::Selector.new @weights[:first_letter]
        @selectors[:first].select
      end
    end

    def next_letter(current_letter)
      if defined?(@next_weight) && @next_weight.has_key?(current_letter)
        @selectors[:next][current_letter] ||= WeightedSelect::Selector.new @next_weight[current_letter]
        @selectors[:next][current_letter].select
      end
    end

    def next_letter!(current_letter)
      next_letter(current_letter) || first_letter.to_s
    end

    def last_letter(penultimate_letter)
      if defined?(@last_weight) && @last_weight.has_key?(penultimate_letter)
        @selectors[:last][penultimate_letter] ||= WeightedSelect::Selector.new @last_weight[penultimate_letter]
        @selectors[:last][penultimate_letter].select
      end
    end

    def last_letter!(penultimate_letter)
      last_letter(penultimate_letter) || next_letter!(penultimate_letter)
    end

    def add_next_weight(letter, next_letter, weight = 1)
      @next_weight         ||= Hash.new
      @next_weight[letter] = Hash.new(0) unless @next_weight.has_key? letter

      @next_weight[letter][next_letter] += Integer weight
    end

    def add_last_weight(penultimate_letter, last_letter, weight = 1)
      @last_weight                     ||= Hash.new
      @last_weight[penultimate_letter] = Hash.new(0) unless @last_weight.has_key? penultimate_letter

      @last_weight[penultimate_letter][last_letter] += Integer weight
    end

    def add_words_weight(word_count, weight = 1)
      @words_weight ||= Hash.new(0)

      @words_weight[word_count] += Integer weight
    end

    def add_sentences_weight(sentence_count, weight = 1)
      @sentences_weight ||= Hash.new(0)

      @sentences_weight[sentence_count] += Integer weight
    end

    # @param [String] word
    def add_word(word)
      add_weight :letter_count, word.length
      add_weight :first_letter, word[0]
      (word.length - 1).times { |l| add_next_weight word[l], word[l.succ] }
      add_last_weight word[-2], word[-1]
    end

    def add_sentence(sentence)
      words = sentence.split(/\s+/)
      add_words_weight words.length
      words.each do |word|
        stripped_word = word.gsub(/[^[:word:]-]/u, '')
        add_word Unicode.downcase(stripped_word) unless stripped_word == ''
      end
    end

    def add_passage(passage)
      sentences = passage.split(/[?!.]/).select { |sentence| sentence.chomp != '' }
      sentences.each { |sentence| add_sentence sentence }
      add_sentences_weight sentences.count
    end

    def add_weight(category, item, weight = 1)
      @weights[category] ||= Hash.new(0)

      @weights[category][item] += Integer weight
    end

    private

    def weighted(category)
      if @weights.has_key? category
        @selectors[category] ||= WeightedSelect::Selector.new @weights[category]
        @selectors[category].select
      end
    end

    def word_length
      if @weights.has_key? :letter_count
        @selectors[:letters] ||= WeightedSelect::Selector.new @weights[:letter_count]
        @selectors[:letters].select
      else
        0
      end
    end

    def sentence_length
      if defined? @words_weight
        @selectors[:words] ||= WeightedSelect::Selector.new @words_weight
        @selectors[:words].select
      else
        0
      end
    end

    def passage_length
      if defined? @sentences_weight
        @selectors[:sentences] ||= WeightedSelect::Selector.new @sentences_weight
        @selectors[:sentences].select
      else
        0
      end
    end
  end
end
