class Plasper
  def word(min_length = 0, max_length = 0)
    word_length  = output_length min_length, max_length
    word, length = '', 0
    while length < word_length
      letter = rand(100) > 80 ? consonant : vowel
      word += letter
      length += 1
    end

    word
  end

  def sentence(min_length = 0, max_length = 0)
    sentence_length = output_length min_length, max_length
    sentence, length = [], 0
    while length < sentence_length
      sentence << word
      length += 1
    end

    sentence.join(' ').capitalize + '.'
  end

  def passage(min_length = 0, max_length = 0)
    passage_length = output_length min_length, max_length
    passage, length = [], 0
    while length < passage_length
      passage << sentence
      length += 1
    end

    passage.join(' ')
  end

  def vowel
    %w{e u i o a}.sample
  end

  def consonant
    %w{q w r t y p s d f g h j k l z x c v b n m}.sample
  end

  private

  def output_length(min_length, max_length)
    min_length = rand(2) if min_length < 1
    max_length = min_length + rand(10) if max_length < min_length

    rand(max_length - min_length) + min_length
  end
end