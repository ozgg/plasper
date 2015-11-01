require 'plasper'

RSpec.describe Plasper::Plasper do
  let(:plasper) { Plasper::Plasper.new }

  describe '#add_letter_weight' do
    it 'counts letter_weight for letter' do
      plasper.add_letter_weight 'w', 2
      expect(plasper.letter_weight['w']).to eq(2)
    end

    it 'uses 1 as default weight' do
      plasper.add_letter_weight 'w', 3
      expect { plasper.add_letter_weight 'w' }.to change { plasper.letter_weight['w'] }.by(1)
    end

    it 'increases letter_weight for letter' do
      plasper.add_letter_weight 'w'
      expect { plasper.add_letter_weight 'w', 3}.to change { plasper.letter_weight['w'] }.by(3)
    end
  end

  describe '#add_word' do
    it 'adds length weight' do
      plasper.add_word 'sample'
      expect(plasper.length_weight[6]).to eq(1)
    end

    it 'increases length weight for existing words' do
      plasper.add_word 'first'
      plasper.add_word 'other'
      expect(plasper.length_weight[5]).to eq(2)
    end

    it 'increases letter weight for each letter' do
      expect(plasper).to receive(:add_letter_weight).exactly(3).times
      plasper.add_word 'hey'
    end

    it 'adds first_letter weight' do
      plasper.add_word 'шило'
      expect(plasper.first_letters['ш']).to eq(1)
    end

    it 'increases first_letter weight' do
      plasper.add_word 'шашки'
      plasper.add_word 'шлем'
      expect(plasper.first_letters['ш']).to eq(2)
    end

    it 'adds next letter weight' do
      plasper.add_word 'adds'
      expect(plasper.next_letters['d']).to eq('d' => 1, 's' => 1)
    end

    it 'increases next letter weight' do
      plasper.add_word 'adds'
      plasper.add_word 'pods'
      expect(plasper.next_letters['d']).to eq('d' => 1, 's' => 2)
    end

    it 'includes nil in next letter weight for last letter' do
      plasper.add_word 'nils'
      expect(plasper.next_letters['s']).to have_key(nil)
    end
  end

  describe '#add_sentence' do
    it 'splits sentence into words by whitespace' do
      expect_any_instance_of(String).to receive(:split).with(/\s+/).and_return([])
      plasper.add_sentence 'Красные пятки торчат из грядки!'
    end

    it 'adds number of words in sentence' do
      plasper.add_sentence 'Красные пятки торчат из грядки?'
      expect(plasper.word_count[5]).to eq(1)
    end

    it 'increases number of words in sentence' do
      plasper.add_sentence 'In three words...'
      plasper.add_sentence 'This is right!'
      expect(plasper.word_count[3]).to eq(2)
    end

    it 'strips punctuation characters'
    it 'passes each word to #add_word'
  end
end
