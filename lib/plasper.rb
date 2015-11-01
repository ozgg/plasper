require 'unicode'

module Plasper
  class Plasper
    attr_reader :length_weight, :first_weight, :next_weight, :last_weight
    attr_reader :words_weight, :sentences_weight

    def initialize
      @selectors = { next: Hash.new, last: Hash.new }
    end

    def first_letter
      if defined? @first_weight
        @selectors[:first] ||= WeightedSelect::Selector.new @first_weight
        @selectors[:first].select
      end
    end

    def next_letter(current_letter)
      if defined?(@next_weight) && @next_weight.has_key?(current_letter)
        @selectors[:next][current_letter] ||= WeightedSelect::Selector.new @next_weight[current_letter]
        @selectors[:next][current_letter].select
      end
    end

    def last_letter(penultimate_letter)
      if defined?(@last_weight) && @last_weight.has_key?(penultimate_letter)
        @selectors[:last][penultimate_letter] ||= WeightedSelect::Selector.new @last_weight[penultimate_letter]
        @selectors[:last][penultimate_letter].select
      end
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

    def add_last_weight(penultimate_letter, last_letter, weight = 1)
      @last_weight ||= Hash.new
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
      add_length_weight word.length
      add_first_weight word[0]
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
  end
end
