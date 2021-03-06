require 'plasper'
require 'weighted-select'

RSpec.describe Plasper::Plasper do
  let(:plasper) { Plasper::Plasper.new }

  describe '#add_weight' do
    it 'uses 1 as default weight' do
      plasper.add_weight :first, :letter, 'q'
      expect(plasper.weights[:first][:letter]['q']).to eq(1)
    end

    it 'uses explicitly set weight' do
      plasper.add_weight :first, :letter, 'q', 2
      expect(plasper.weights[:first][:letter]['q']).to eq(2)
    end

    it 'increments weight for key' do
      plasper.add_weight :first, :letter, 'q', 4
      expect { plasper.add_weight(:first, :letter, 'q', 3) }.to change { plasper.weights[:first][:letter]['q'] }.by(3)
    end
  end

  describe '#weighted' do
    it 'returns nil when category is not present in @weights' do
      expect(plasper.send(:weighted, :first, :letter)).to be_nil
    end

    it 'returns weighted-random for existing category' do
      expect_any_instance_of(WeightedSelect::Selector).to receive(:select)
      plasper.add_weight :first, :letter, 'a'
      plasper.send(:weighted, :first, :letter)
    end
  end

  describe '#word=' do
    before(:each) { allow(plasper).to receive(:add_weight).and_call_original }

    it 'increases letter count weight for word length' do
      expect(plasper).to receive(:add_weight).with(:count, :letter, 5).once
      plasper.word = 'hello'
    end

    it 'increases first letter weight for letter' do
      expect(plasper).to receive(:add_weight).with(:first, :letter, 'y').once
      plasper.word = 'yay'
    end

    it 'increases next letter weights for each letter' do
      expect(plasper).to receive(:add_weight).with(:next, any_args).exactly(4).times
      plasper.word = 'слово'
    end

    it 'increases last letter weights for each letter' do
      expect(plasper).to receive(:add_weight).with(:last, 'в', 'о').once
      plasper.word = 'слово'
    end

    it 'does not include nil in next letter weights for the last letter' do
      plasper.word = 'snakes'
      expect(plasper.weights[:next]['s']).not_to have_key(nil)
    end

    it 'includes nil in last letter weight for 1-letter word' do
      plasper.word = 'в'
      expect(plasper.weights[:last]).to have_key(nil)
    end
  end

  describe '#sentence=' do
    before(:each) { allow(plasper).to receive(:add_weight).and_call_original }

    it 'splits sentence into words by whitespace' do
      expect_any_instance_of(String).to receive(:split).with(/\s+/).and_call_original
      plasper.sentence = 'Красные пятки торчат из грядки!'
    end

    it 'adds word count weight for number of words in sentence' do
      expect(plasper).to receive(:add_weight).with(:count, :word, 5).once
      plasper.sentence = 'Красные пятки торчат из грядки?'
    end

    it 'strips punctuation characters' do
      expect_any_instance_of(String).to receive(:gsub).and_call_original
      plasper.sentence = '"«Ага!»"?юю...'
    end

    it 'keeps dashes' do
      plasper.sentence = 'Чудо-юдо рыба-кит.'
      expect(plasper.weights[:next]).to have_key('-')
    end

    it 'casts each word to lowercase' do
      expect(Unicode).to receive(:downcase).and_call_original
      plasper.sentence = 'Бывает!'
    end

    it 'passes each reasonable word to #word=' do
      expect(plasper).to receive(:word=).twice
      plasper.sentence = 'Какая чудесная ***!'
    end
  end

  describe '#passage=' do
    before(:each) { allow(plasper).to receive(:add_weight).and_call_original }

    it 'splits passage to sentences' do
      passage = 'Ночь, улица. Фонарь? Ещё и аптека!'
      expect(passage).to receive(:split).and_call_original
      plasper.passage = passage
    end

    it 'adds each non-empty sentence' do
      passage = 'Давно. А?! Это было давно?...'
      expect(plasper).to receive(:sentence=).exactly(3).times
      plasper.passage = passage
    end

    it 'counts sentences weight with non-empty sentence count' do
      passage = 'Деда... Это... Опа.'
      expect(plasper).to receive(:add_weight).with(:count, :sentence, 3)
      plasper.passage = passage
    end
  end

  describe '#first_letter' do
    it 'calls #weighted with :first_letter' do
      expect(plasper).to receive(:weighted).with(:first, :letter)
      plasper.send :first_letter
    end
  end

  describe '#next_letter' do
    it 'calls #weighted with :next and letter' do
      expect(plasper).to receive(:weighted).with(:next, 'q')
      plasper.send :next_letter, 'q'
    end
  end

  describe '#next_letter!' do
    it 'calls #next_letter' do
      expect(plasper).to receive(:next_letter).with('a').once
      plasper.send :next_letter!, 'a'
    end

    it 'falls back to #first_letter' do
      allow(plasper).to receive(:next_letter).and_return(nil)
      expect(plasper).to receive(:first_letter)
      plasper.send :next_letter!, 'b'
    end
  end

  describe '#last_letter' do
    it 'calls #weighted with :last and letter' do
      expect(plasper).to receive(:weighted).with(:last, 'q')
      plasper.send :last_letter, 'q'
    end
  end

  describe '#last_letter!' do
    it 'calls #last_letter' do
      expect(plasper).to receive(:last_letter).with('a').once
      plasper.send :last_letter!, 'a'
    end

    it 'falls back to #next_letter!' do
      allow(plasper).to receive(:last_letter).and_return(nil)
      expect(plasper).to receive(:next_letter!).with('b')
      plasper.send :last_letter!, 'b'
    end
  end

  describe '#word' do
    it 'selects random word length by weight once' do
      expect(plasper).to receive(:weighted).with(:count, :letter).once.and_return(0)
      plasper.word
    end

    context 'when length is one letter' do
      before(:each) { allow(plasper).to receive(:weighted).with(:count, :letter).and_return(1) }

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
      before(:each) { allow(plasper).to receive(:weighted).with(:count, :letter).and_return(2) }

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
      before(:each) { allow(plasper).to receive(:weighted).with(:count, :letter).and_return(4) }

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
      expect(plasper).to receive(:weighted).with(:count, :word).and_return(0)
      plasper.sentence
    end

    it 'calls #word necessary number of times' do
      allow(plasper).to receive(:weighted).with(:count, :word).and_return(3)
      expect(plasper).to receive(:word).exactly(3).times
      plasper.sentence
    end

    it 'joins result of #word invocations with space' do
      allow(plasper).to receive(:weighted).with(:count, :word).and_return(3)
      allow(plasper).to receive(:word).and_return('good')
      expect(plasper.sentence.scan(' ').length).to eq(2)
    end

    it 'capitalizes the first letter of sentence' do
      allow(plasper).to receive(:weighted).with(:count, :word).and_return(3)
      allow(plasper).to receive(:word).and_return('good')
      expect(Unicode).to receive(:upcase).with('g').once.and_call_original
      plasper.sentence
    end
  end

  describe '#passage' do
    it 'determines sentence count once' do
      expect(plasper).to receive(:weighted).with(:count, :sentence).and_return(0)
      plasper.passage
    end

    it 'calls #sentence necessary number of times' do
      allow(plasper).to receive(:weighted).with(:count, :sentence).and_return(5)
      expect(plasper).to receive(:sentence).exactly(5).times
      plasper.passage
    end

    it 'joins result of #sentence invocations with dot' do
      allow(plasper).to receive(:weighted).with(:count, :sentence).and_return(3)
      allow(plasper).to receive(:sentence).and_return('It works')
      expect(plasper.passage.scan('. ').length).to eq(2)
    end
  end

  describe '#<<' do
    context 'when input is single word' do
      let!(:input) { 'Hello!' }

      it 'strips characters that are not letters' do
        expect(input).to receive(:gsub).once.and_call_original
        plasper << input
      end

      it 'casts word to lowercase' do
        expect(Unicode).to receive(:downcase).with('Hello').and_call_original
        plasper << input
      end

      it 'analyzes word if it is not empty' do
        expect(plasper).to receive(:word=).with('hello')
        plasper << input
      end

      it 'does not analyze word if it is empty' do
        expect(plasper).not_to receive(:word=)
        plasper << '?!'
      end
    end

    context 'when input is sentence' do
      let!(:input) { 'Красные пятки торчат из грядки?' }

      it 'strips sentence delimiters' do
        expect(input).to receive(:gsub).with(Plasper::Plasper::SENTENCE_DELIMITER, any_args).once.and_call_original
        plasper << input
      end

      it 'analyzes input as sentence' do
        expect(plasper).to receive(:sentence=).with('Красные пятки торчат из грядки')
        plasper << input
      end
    end

    context 'when input is passage' do
      it 'analyzes input as passage' do
        input = 'Первое предложение. Второе тоже тут будет.'
        expect(plasper).to receive(:passage=).with(input).once
        plasper << input
      end
    end
  end
end
