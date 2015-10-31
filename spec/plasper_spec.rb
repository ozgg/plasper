require 'plasper'

describe Plasper::Plasper do
  let(:plasper) { Plasper::Plasper.new }

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

    it 'counts letter weight for each letter in word' do
      plasper.add_word 'ага'
      expect(plasper.letter_weight).to eq('а' => 2, 'г' => 1)
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
    pending
  end
end