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

    it 'adds first_letter weight'
    it 'increases first_letter weight'
    it 'adds next letter weight'
    it 'increases next letter weight'
  end

  describe '#add_sentence' do

  end
end