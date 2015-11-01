require 'plasper'

RSpec.describe Plasper::Plasper do
  let(:plasper) { Plasper::Plasper.new }

  describe '#add_letter_weight' do
    it 'uses 1 as default weight' do
      plasper.add_letter_weight 'w'
      expect(plasper.letter_weight['w']).to eq(1)
    end

    it 'counts letter_weight for letter' do
      plasper.add_letter_weight 'w', 3
      expect(plasper.letter_weight['w']).to eq(3)
    end

    it 'increases letter_weight for letter' do
      plasper.add_letter_weight 'w'
      expect { plasper.add_letter_weight 'w', 3 }.to change { plasper.letter_weight['w'] }.by(3)
    end
  end

  describe '#add_length_weight' do
    it 'uses 1 as default weight' do
      plasper.add_length_weight 6
      expect(plasper.length_weight[6]).to eq(1)
    end

    it 'counts length_weight for length' do
      plasper.add_length_weight 6, 3
      expect(plasper.length_weight[6]).to eq(3)
    end

    it 'increases length_weight for length' do
      plasper.add_length_weight 6
      expect { plasper.add_length_weight 6, 3 }.to change { plasper.length_weight[6] }.by(3)
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

    it 'increases first_weight for letter' do
      plasper.add_next_weight 'q', 'w'
      expect { plasper.add_next_weight 'q', 'w', 2 }.to change { plasper.next_weight['q']['w'] }.by(2)
    end

    it 'does not change weights for other letters' do
      plasper.add_next_weight 'q', 'w'
      plasper.add_next_weight 's', 'w'
      expect { plasper.add_next_weight 'q', 'w' }.not_to change { plasper.next_weight['s']['w'] }
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

  describe '#add_sentences_weight', focus: true do
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
    it 'increases length weight for word length' do
      expect(plasper).to receive(:add_length_weight).with(5).once
      plasper.add_word 'hello'
    end

    it 'increases letter weight for each letter' do
      expect(plasper).to receive(:add_letter_weight).exactly(3).times
      plasper.add_word 'hey'
    end

    it 'increases first letter weight for letter' do
      expect(plasper).to receive(:add_first_weight).with('y').once
      plasper.add_word 'yay'
    end

    it 'increases next letter weights for each letter' do
      expect(plasper).to receive(:add_next_weight).exactly(5).times
      plasper.add_word 'слово'
    end

    it 'includes nil in next letter weight for the last letter' do
      plasper.add_word 'nils'
      expect(plasper.next_weight['s']).to have_key(nil)
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
      expect(plasper.letter_weight).to have_key('-')
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

  describe '#add_passage', focus: true do
    it 'splits passage to sentences'
    it 'adds each non-empty sentence'
    it 'counts sentences weight'
  end
end
