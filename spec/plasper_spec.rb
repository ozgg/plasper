require 'plasper'
require 'weighted-select'

RSpec.describe Plasper::Plasper do
  let(:plasper) { Plasper::Plasper.new }

  describe '#add_weight' do
    it 'uses 1 as default weight' do
      plasper.add_weight :a, :b, 6
      expect(plasper.weights[:a][:b][6]).to eq(1)
    end

    it 'uses explicitly set weight' do
      plasper.add_weight :a, :b, 5, 2
      expect(plasper.weights[:a][:b][5]).to eq(2)
    end

    it 'increments weight for key' do
      plasper.add_weight :a, :b, 7, 4
      expect { plasper.add_weight(:a, :b, 7, 3) }.to change { plasper.weights[:a][:b][7] }.by(3)
    end
  end

  describe '#weighted' do
    it 'returns nil when category is not present in @weights' do
      expect(plasper.send(:weighted, :nothing, :at_all)).to be_nil
    end

    it 'returns weighted-random for existing category' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_weight :flat, :first_letter, 'a'
      plasper.send(:weighted, :flat, :first_letter)
    end
  end

  describe '#weighted_letter' do
    it 'returns nil when letter is not present in @letters' do
      expect(plasper.send(:weighted_letter, :next, 'a')).to be_nil
    end

    it 'returns weighted-random for existing letter in category' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_letter :next, 'q', 'w'
      plasper.send(:weighted_letter, :next, 'q')
    end
  end

  describe '#add_word' do
    before(:each) do
      allow(plasper).to receive(:add_weight).and_call_original
      allow(plasper).to receive(:add_letter).and_call_original
    end

    it 'increases letter count weight for word length' do
      expect(plasper).to receive(:add_weight).with(:flat, :letter_count, 5).once
      plasper.add_word 'hello'
    end

    it 'increases first letter weight for letter' do
      expect(plasper).to receive(:add_weight).with(:flat, :first_letter, 'y').once
      plasper.add_word 'yay'
    end

    it 'increases next letter weights for each letter' do
      expect(plasper).to receive(:add_letter).with(:next, any_args).exactly(4).times
      plasper.add_word 'слово'
    end

    it 'increases last letter weights for each letter' do
      expect(plasper).to receive(:add_letter).with(:last, 'в', 'о').once
      plasper.add_word 'слово'
    end

    it 'does not include nil in next letter weights for the last letter' do
      plasper.add_word 'snakes'
      expect(plasper.letters[:next]['s']).not_to have_key(nil)
    end

    it 'includes nil in last letter weight for 1-letter word' do
      plasper.add_word 'в'
      expect(plasper.letters[:last]).to have_key(nil)
    end
  end

  describe '#add_sentence' do
    before(:each) do
      allow(plasper).to receive(:add_weight).and_call_original
      allow(plasper).to receive(:add_letter).and_call_original
    end

    it 'splits sentence into words by whitespace' do
      expect_any_instance_of(String).to receive(:split).with(/\s+/).and_call_original
      plasper.add_sentence 'Красные пятки торчат из грядки!'
    end

    it 'adds word count weight for number of words in sentence' do
      expect(plasper).to receive(:add_weight).with(:flat, :word_count, 5).once
      plasper.add_sentence 'Красные пятки торчат из грядки?'
    end

    it 'strips punctuation characters' do
      expect_any_instance_of(String).to receive(:gsub).and_call_original
      plasper.add_sentence '"«Ага!»"?юю...'
    end

    it 'keeps dashes' do
      plasper.add_sentence 'Чудо-юдо рыба-кит.'
      expect(plasper.letters[:next]).to have_key('-')
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
    before(:each) { allow(plasper).to receive(:add_weight).and_call_original }

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
      expect(plasper).to receive(:add_weight).with(:flat, :sentence_count, 3)
      plasper.add_passage passage
    end
  end

  describe '#first_letter' do
    it 'calls #weighted with :first_letter' do
      expect(plasper).to receive(:weighted).with(:flat, :first_letter)
      plasper.first_letter
    end
  end

  describe '#next_letter' do
    it 'returns nil when next_weight is empty' do
      expect(plasper.next_letter 'a').to be_nil
    end

    it 'returns nil when letter is not present in next_weight' do
      plasper.add_letter :next, 'a', 'b'
      expect(plasper.next_letter 'b').to be_nil
    end

    it 'returns weighted-random letter from next-letter weights' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_letter :next, 'a', 'b'
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
      plasper.add_letter :last, 'a', 'b'
      expect(plasper.last_letter 'b').to be_nil
    end

    it 'returns weighted-random letter from last-letter weights' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_letter :last, 'a', 'b'
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

  describe '#word' do
    it 'selects random word length by weight once' do
      expect(plasper).to receive(:weighted).with(:flat, :letter_count).once.and_return(0)
      plasper.word
    end

    context 'when length is one letter' do
      before(:each) { allow(plasper).to receive(:weighted).with(:flat, :letter_count).and_return(1) }

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
      before(:each) { allow(plasper).to receive(:weighted).with(:flat, :letter_count).and_return(2) }

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
      before(:each) { allow(plasper).to receive(:weighted).with(:flat, :letter_count).and_return(4) }

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
      expect(plasper).to receive(:weighted).with(:flat, :word_count).and_return(0)
      plasper.sentence
    end

    it 'calls #word necessary number of times' do
      allow(plasper).to receive(:weighted).with(:flat, :word_count).and_return(3)
      expect(plasper).to receive(:word).exactly(3).times
      plasper.sentence
    end

    it 'joins result of #word invocations with space' do
      allow(plasper).to receive(:weighted).with(:flat, :word_count).and_return(3)
      allow(plasper).to receive(:word).and_return('good')
      expect(plasper.sentence.scan(' ').length).to eq(2)
    end

    it 'capitalizes the first letter of sentence' do
      allow(plasper).to receive(:weighted).with(:flat, :word_count).and_return(3)
      allow(plasper).to receive(:word).and_return('good')
      expect(Unicode).to receive(:upcase).with('g').once.and_call_original
      plasper.sentence
    end
  end

  describe '#passage' do
    it 'determines sentence count once' do
      expect(plasper).to receive(:weighted).with(:flat, :sentence_count).and_return(0)
      plasper.passage
    end

    it 'calls #sentence necessary number of times' do
      allow(plasper).to receive(:weighted).with(:flat, :sentence_count).and_return(5)
      expect(plasper).to receive(:sentence).exactly(5).times
      plasper.passage
    end

    it 'joins result of #sentence invocations with dot' do
      allow(plasper).to receive(:weighted).with(:flat, :sentence_count).and_return(3)
      allow(plasper).to receive(:sentence).and_return('It works')
      expect(plasper.passage.scan('. ').length).to eq(2)
    end
  end
end
