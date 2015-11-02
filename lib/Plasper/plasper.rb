module Plasper
  class Plasper
    attr_reader :weights

    SENTENCE_DELIMITER = /[?!.]/

    # Prepares selectors and weights storage
    def initialize
      @weights = { count: {}, first: {}, next: {}, last: {} }
    end

    # Analyze input and add appropriate part
    #
    # Determines if input is word, sentence or passage and adds it
    #
    # @param [String] input
    def <<(input)
      if input.index(/\s+/).nil?
        word      = normalize_word input
        self.word = word unless word == ''
      elsif input.scan(SENTENCE_DELIMITER).length < 2
        self.sentence = input.gsub(SENTENCE_DELIMITER, '')
      else
        self.passage = input
      end
    end

    # Analyze word
    #
    # Adds weights for first, next and last letters and letter count
    #
    # @param [String] word
    def word=(word)
      add_weight :count, :letter, word.length
      add_weight :first, :letter, word[0]
      (word.length - 1).times { |l| add_weight :next, word[l], word[l.succ] }
      add_weight :last, word[-2], word[-1]
    end

    # Generate word
    #
    # @return [String]
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

    # Analyze sentence
    #
    # Splits sentence with whitespace delimiter, adds weight for word count and analyzes each word
    #
    # @param [String] sentence
    def sentence=(sentence)
      words = sentence.split(/\s+/)
      add_weight :count, :word, words.length
      words.each do |word|
        normalized_word = normalize_word word
        self.word       = normalized_word unless normalized_word == ''
      end
    end

    # Generate sentence
    #
    # @return [String]
    def sentence
      string    = word_count.times.map { word }.join(' ')
      string[0] = Unicode.upcase(string[0]) unless string.to_s == ''
      string
    end

    # Analyze passage
    #
    # Splits passage with sentence-ending punctuation, adds sentence count weight and analyzes each sentence
    #
    # @param [String] passage
    def passage=(passage)
      sentences = passage.split(SENTENCE_DELIMITER).select { |sentence| sentence.chomp != '' }
      sentences.each { |sentence| self.sentence = sentence }
      add_weight :count, :sentence, sentences.count
    end

    # Generate passage
    #
    # @return [String]
    def passage
      sentence_count.times.map { sentence }.join('. ')
    end

    # Add weight
    #
    # Used for adding weights for counters, first, next and last letter.
    # Valid types are :count, :first, :next and :last (@see #initialize)
    # Group is either symbol (e.g. :letters, :words, :sentences, :letter), or string representing letter
    # Item is integer (letter, word and sentence count) or string representing letter
    # Weight is used for weighted-select in generation methods
    #
    # @param [Symbol] type
    # @param [Symbol|String] group
    # @param [String|Integer] item
    # @param [Integer] weight
    def add_weight(type, group, item, weight = 1)
      @weights[type][group] ||= Hash.new(0)

      @weights[type][group][item] += Integer weight
    end

    private

    def normalize_word(word)
      Unicode.downcase word.gsub(/[^[:word:]'-]/u, '')
    end

    # Generate weighted-random value
    #
    # Type is :count, :first, :next or :last
    # Group is symbol (for member count or first letter) or string representing letter
    #
    # @param [Symbol] type
    # @param [Symbol|String] group
    def weighted(type, group)
      if @weights[type].has_key?(group)
        selector = WeightedSelect::Selector.new @weights[type][group]
        selector.select
      end
    end

    # Generate first letter
    #
    # @return [String]
    def first_letter
      weighted :first, :letter
    end

    # Generate next letter for current one
    #
    # @param [String] current_letter
    # @return [String]
    def next_letter(current_letter)
      weighted :next, current_letter
    end

    # Generate next letter with fallback
    #
    # If there are no weights with next letters for current_letter,
    # try to generate another first letter instead and use it
    #
    # @param [String] current_letter
    # @return [String]
    def next_letter!(current_letter)
      next_letter(current_letter) || first_letter.to_s
    end

    # Generate last letter after penultimate letter
    #
    # @param [String] penultimate_letter
    # @return [String]
    def last_letter(penultimate_letter)
      weighted :last, penultimate_letter
    end

    # Generate last letter with fallback to #next_letter!
    #
    # If there are no weights for last letter after given one, try to fall back to next_letter
    #
    # @param [String] penultimate_letter
    # @return [String]
    def last_letter!(penultimate_letter)
      last_letter(penultimate_letter) || next_letter!(penultimate_letter)
    end

    # Weighted-randomly select word count
    #
    # Used when generating #sentence
    #
    # @return [Integer]
    def word_count
      weighted(:count, :word).to_i
    end

    # Weighted-randomly select sentence count
    #
    # Used when generating #passage
    #
    # @return [Integer]
    def sentence_count
      weighted(:count, :sentence).to_i
    end
  end
end
