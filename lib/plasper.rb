class Plasper
  attr_accessor :word_range, :sentence_range, :passage_range, :vowels, :consonants

  def initialize
    @word_range     = { 1 => 1, 2 => 2, 3 => 3, 4 => 5, 5 => 5, 6 => 6, 7 => 4, 8 => 2, 9 => 1 }
    @sentence_range = { 1 => 1, 2 => 1, 3 => 2, 4 => 2, 5 => 3, 6 => 4, 7 => 5, 8 => 4, 9 => 2 }
    @passage_range  = { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 3, 6 => 2, 7 => 1, 8 => 1, 9 => 1 }
    @vowels         = { e: 1, u: 1, i: 1, o: 1, a: 1 }
    @consonants     = {
        q: 1, w: 1, r: 2, t: 2, y: 2, p: 2, s: 3, d: 3, f: 4, g: 3,
        h: 3, j: 3, k: 3, l: 2, z: 1, x: 1, c: 2, v: 2, b: 2, n: 2, m: 2
    }
  end

  def word
    word_length  = weighted_select(@word_range).to_i
    word, length = '', 0
    while length < word_length
      letter = rand(100) < 40 ? consonant : vowel
      word   += letter
      length += 1
    end

    word
  end

  def sentence
    sentence_length  = weighted_select(@sentence_range).to_i
    sentence, length = [], 0
    while length < sentence_length
      sentence << word
      length += 1
    end

    sentence.join(' ').capitalize + '.'
  end

  def passage
    passage_length  = weighted_select(@passage_range).to_i
    passage, length = [], 0
    while length < passage_length
      passage << sentence
      length += 1
    end

    passage.join(' ')
  end

  def vowel
    weighted_select @vowels
  end

  def consonant
    weighted_select @consonants
  end

  private

  def weighted_select(rules)
    buffer = []
    rules.each do |item, weight|
      weight.times { buffer << item }
    end

    buffer.sample.to_s
  end
end