require 'plasper'
require 'weighted-select'

RSpec.describe Plasper::Plasper do
  let(:plasper) { Plasper::Plasper.new }

  describe '#add_weight' do
    it 'uses 1 as default weight' do
      plasper.add_weight :letters, 6
      expect(plasper.weights[:letters][6]).to eq(1)
    end

    it 'uses explicitly set weight' do
      plasper.add_weight :letters, 5, 2
      expect(plasper.weights[:letters][5]).to eq(2)
    end

    it 'increments weight for key' do
      plasper.add_weight :letters, 7, 4
      expect { plasper.add_weight(:letters, 7, 3) }.to change { plasper.weights[:letters][7] }.by(3)
    end
  end

  describe '#add_first_weight' do
    it 'uses 1 as default weight' do
      plasper.add_first_weight 'w'
      expect(plasper.first_weight['w']).to eq(1)
    end

    it 'counts first_weight for letter' do
      plasper.add_first_weight 'w', 3
      expect(plasper.first_weight['w']).to eq(3)
    end

    it 'increases first_weight for letter' do
      plasper.add_first_weight 'w'
      expect { plasper.add_first_weight 'w', 3 }.to change { plasper.first_weight['w'] }.by(3)
    end
  end

  describe '#add_next_weight' do
    it 'uses 1 as default weight' do
      plasper.add_next_weight 'q', 'w'
      expect(plasper.next_weight['q']['w']).to eq(1)
    end

    it 'counts next_weight for following letter' do
      plasper.add_next_weight 'q', 'w', 3
      expect(plasper.next_weight['q']['w']).to eq(3)
    end

    it 'increases next_weight for letter' do
      plasper.add_next_weight 'q', 'w'
      expect { plasper.add_next_weight 'q', 'w', 2 }.to change { plasper.next_weight['q']['w'] }.by(2)
    end

    it 'does not change weights for other letters' do
      plasper.add_next_weight 'q', 'w'
      plasper.add_next_weight 's', 'w'
      expect { plasper.add_next_weight 'q', 'w' }.not_to change { plasper.next_weight['s']['w'] }
    end
  end

  describe '#add_last_weight' do
    it 'uses 1 as default weight' do
      plasper.add_last_weight 'q', 'w'
      expect(plasper.last_weight['q']['w']).to eq(1)
    end

    it 'counts last_weight for previous letter' do
      plasper.add_last_weight 'q', 'w', 3
      expect(plasper.last_weight['q']['w']).to eq(3)
    end

    it 'increases last_weight for letter' do
      plasper.add_last_weight 'q', 'w'
      expect { plasper.add_last_weight 'q', 'w', 2 }.to change { plasper.last_weight['q']['w'] }.by(2)
    end

    it 'does not change weights for other letters' do
      plasper.add_last_weight 'q', 'w'
      plasper.add_last_weight 's', 'w'
      expect { plasper.add_last_weight 'q', 'w' }.not_to change { plasper.last_weight['s']['w'] }
    end
  end

  describe '#add_words_weight' do
    it 'uses 1 as default weight' do
      plasper.add_words_weight 6
      expect(plasper.words_weight[6]).to eq(1)
    end

    it 'counts words_weight for length' do
      plasper.add_words_weight 6, 3
      expect(plasper.words_weight[6]).to eq(3)
    end

    it 'increases words_weight for length' do
      plasper.add_words_weight 6
      expect { plasper.add_words_weight 6, 3 }.to change { plasper.words_weight[6] }.by(3)
    end
  end

  describe '#add_sentences_weight' do
    it 'uses 1 as default weight' do
      plasper.add_sentences_weight 6
      expect(plasper.sentences_weight[6]).to eq(1)
    end

    it 'counts sentences_weight for length' do
      plasper.add_sentences_weight 6, 3
      expect(plasper.sentences_weight[6]).to eq(3)
    end

    it 'increases sentences_weight for length' do
      plasper.add_sentences_weight 6
      expect { plasper.add_sentences_weight 6, 3 }.to change { plasper.sentences_weight[6] }.by(3)
    end
  end

  describe '#add_word' do
    it 'increases letter count weight for word length' do
      expect(plasper).to receive(:add_weight).with(:letter_count, 5).once
      plasper.add_word 'hello'
    end

    it 'increases first letter weight for letter' do
      expect(plasper).to receive(:add_first_weight).with('y').once
      plasper.add_word 'yay'
    end

    it 'increases next letter weights for each letter' do
      expect(plasper).to receive(:add_next_weight).exactly(4).times
      plasper.add_word 'слово'
    end

    it 'increases last letter weights for each letter' do
      expect(plasper).to receive(:add_last_weight).once
      plasper.add_word 'слово'
    end

    it 'does not include nil in next letter weights for the last letter' do
      plasper.add_word 'snakes'
      expect(plasper.next_weight['s']).not_to have_key(nil)
    end

    it 'includes nil in last letter weight for 1-letter word' do
      plasper.add_word 'в'
      expect(plasper.last_weight).to have_key(nil)
    end
  end

  describe '#add_sentence' do
    it 'splits sentence into words by whitespace' do
      expect_any_instance_of(String).to receive(:split).with(/\s+/).and_call_original
      plasper.add_sentence 'Красные пятки торчат из грядки!'
    end

    it 'adds words_weight for number of words in sentence' do
      expect(plasper).to receive(:add_words_weight).once.with(5)
      plasper.add_sentence 'Красные пятки торчат из грядки?'
    end

    it 'strips punctuation characters' do
      expect_any_instance_of(String).to receive(:gsub).and_call_original
      plasper.add_sentence '"«Ага!»"?юю...'
    end

    it 'keeps dashes' do
      plasper.add_sentence 'Чудо-юдо рыба-кит.'
      expect(plasper.next_weight).to have_key('-')
    end

    it 'casts each word to lowercase' do
      expect(Unicode).to receive(:downcase).and_call_original
      plasper.add_sentence 'Бывает!'
    end

    it 'passes each reasonable word to #add_word' do
      expect(plasper).to receive(:add_word).twice
      plasper.add_sentence 'Какая чудесная ***!'
    end
  end

  describe '#add_passage' do
    it 'splits passage to sentences' do
      passage = 'Ночь, улица. Фонарь? Ещё и аптека!'
      expect(passage).to receive(:split).and_call_original
      plasper.add_passage passage
    end

    it 'adds each non-empty sentence' do
      passage = 'Давно. А?! Это было давно?...'
      expect(plasper).to receive(:add_sentence).exactly(3).times
      plasper.add_passage passage
    end

    it 'counts sentences weight with non-empty sentence count' do
      passage = 'Деда... Это... Опа.'
      expect(plasper).to receive(:add_sentences_weight).with(3)
      plasper.add_passage passage
    end
  end

  describe '#first_letter' do
    it 'returns nil when no first letter weights present' do
      expect(plasper.first_letter).to be_nil
    end

    it 'returns weighted-random letter from first-letter weights' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_first_weight 'a'
      plasper.first_letter
    end
  end

  describe '#next_letter' do
    it 'returns nil when next_weight is empty' do
      expect(plasper.next_letter 'a').to be_nil
    end

    it 'returns nil when letter is not present in next_weight' do
      plasper.add_next_weight 'a', 'b'
      expect(plasper.next_letter 'b').to be_nil
    end

    it 'returns weighted-random letter from next-letter weights' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_next_weight 'a', 'b'
      plasper.next_letter 'a'
    end
  end

  describe '#next_letter!' do
    it 'calls #next_letter' do
      expect(plasper).to receive(:next_letter).with('a').once
      plasper.next_letter! 'a'
    end

    it 'falls back to #first_letter' do
      allow(plasper).to receive(:next_letter).and_return(nil)
      expect(plasper).to receive(:first_letter)
      plasper.next_letter! 'b'
    end
  end

  describe '#last_letter' do
    it 'returns nil when last_weight is empty' do
      expect(plasper.last_letter 'a').to be_nil
    end

    it 'returns nil when letter is not present in last_weight' do
      plasper.add_last_weight 'a', 'b'
      expect(plasper.last_letter 'b').to be_nil
    end

    it 'returns weighted-random letter from last-letter weights' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_last_weight 'a', 'b'
      plasper.last_letter 'a'
    end
  end

  describe '#last_letter!' do
    it 'calls #last_letter' do
      expect(plasper).to receive(:last_letter).with('a').once
      plasper.last_letter! 'a'
    end

    it 'falls back to #next_letter!' do
      allow(plasper).to receive(:last_letter).and_return(nil)
      expect(plasper).to receive(:next_letter!).with('b')
      plasper.last_letter! 'b'
    end
  end

  describe '#word_length' do
    it 'returns 0 when letters_weight is empty' do
      expect(plasper.send(:word_length)).to eq(0)
    end

    it 'returns weighted-random number from letter_weight' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_weight :letter_count, 4
      plasper.send(:word_length)
    end
  end

  describe '#sentence_length' do
    it 'returns 0 when words_weight is empty' do
      expect(plasper.send(:sentence_length)).to eq(0)
    end

    it 'returns weighted-random number from words_weight' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_words_weight 4
      plasper.send(:sentence_length)
    end
  end

  describe '#passage_length' do
    it 'returns 0 when sentences_weight is empty' do
      expect(plasper.send(:passage_length)).to eq(0)
    end

    it 'returns weighted-random number from sentences_weight' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_sentences_weight 4
      plasper.send(:passage_length)
    end
  end

  describe '#word' do
    it 'selects random word length by weight once' do
      expect(plasper).to receive(:word_length).once.and_return(0)
      plasper.word
    end

    context 'when length is one letter' do
      before(:each) { allow(plasper).to receive(:word_length).and_return(1) }

      it 'calls #last_letter! with nil once' do
        expect(plasper).to receive(:last_letter!).with(nil).once
        plasper.word
      end

      it 'does not call #first_letter' do
        allow(plasper).to receive(:last_letter!).and_return('a')
        expect(plasper).not_to receive(:first_letter)
        plasper.word
      end

      it 'does not call #next_letter!' do
        allow(plasper).to receive(:last_letter!).and_return('a')
        expect(plasper).not_to receive(:next_letter!)
        plasper.word
      end
    end

    context 'when length is two letters' do
      before(:each) { allow(plasper).to receive(:word_length).and_return(2) }

      it 'calls #first_letter once' do
        expect(plasper).to receive(:first_letter).once.and_return 'a'
        allow(plasper).to receive(:last_letter!).and_return('')
        plasper.word
      end

      it 'calls #last_letter! with the first letter as argument once' do
        allow(plasper).to receive(:first_letter).and_return('a')
        expect(plasper).to receive(:last_letter!).with('a').once.and_return('b')
        plasper.word
      end

      it 'does not call #next_letter!' do
        allow(plasper).to receive(:first_letter).and_return('')
        allow(plasper).to receive(:last_letter!).and_return('')
        expect(plasper).not_to receive(:next_letter!)
        plasper.word
      end
    end

    context 'when length is more than two letters' do
      before(:each) { allow(plasper).to receive(:word_length).and_return(4) }

      it 'calls #first_letter once' do
        allow(plasper).to receive(:next_letter!).and_return('b')
        allow(plasper).to receive(:last_letter!).and_return('c')
        expect(plasper).to receive(:first_letter).once.and_return('a')
        plasper.word
      end

      it 'calls #next_letter! (word.length - 2) times' do
        allow(plasper).to receive(:first_letter).and_return('a')
        allow(plasper).to receive(:last_letter!).and_return('c')
        expect(plasper).to receive(:next_letter!).twice.and_return('b')
        plasper.word
      end

      it 'calls #last_letter! once' do
        allow(plasper).to receive(:first_letter).and_return('a')
        allow(plasper).to receive(:next_letter!).and_return('b')
        expect(plasper).to receive(:last_letter!).once.and_return('c')
        plasper.word
      end
    end
  end

  describe '#sentence' do
    it 'determines word count once' do
      expect(plasper).to receive(:sentence_length).and_return(0)
      plasper.sentence
    end

    it 'calls #word necessary number of times' do
      allow(plasper).to receive(:sentence_length).and_return(3)
      expect(plasper).to receive(:word).exactly(3).times
      plasper.sentence
    end

    it 'joins result of #word invocations with space' do
      allow(plasper).to receive(:sentence_length).and_return(3)
      allow(plasper).to receive(:word).and_return('good')
      expect(plasper.sentence.scan(' ').length).to eq(2)
    end

    it 'capitalizes the first letter of sentence' do
      allow(plasper).to receive(:sentence_length).and_return(3)
      allow(plasper).to receive(:word).and_return('good')
      expect(Unicode).to receive(:upcase).with('g').once.and_call_original
      plasper.sentence
    end
  end

  describe '#passage' do
    it 'determines sentence count once' do
      expect(plasper).to receive(:passage_length).and_return(0)
      plasper.passage
    end

    it 'calls #sentence necessary number of times' do
      allow(plasper).to receive(:passage_length).and_return(5)
      expect(plasper).to receive(:sentence).exactly(5).times
      plasper.passage
    end

    it 'joins result of #sentence invocations with dot' do
      allow(plasper).to receive(:passage_length).and_return(3)
      allow(plasper).to receive(:sentence).and_return('It works')
      expect(plasper.passage.scan('. ').length).to eq(2)
    end
  end
end
