require 'plasper'

RSpec.describe Plasper::Options do
  context 'paths to files', focus: true do
    it 'assigns file path to text_file when -t is given' do
      options = Plasper::Options.new %w(-t text.txt)
      expect(options.text_file).to eq('text.txt')
    end

    it 'assigns file path to text_file when --text-file is given' do
      options = Plasper::Options.new %w(--text-file text.txt)
      expect(options.text_file).to eq('text.txt')
    end

    it 'assigns file to weights_file when parameter -w is given' do
      options = Plasper::Options.new %w(-w weights.yml)
      expect(options.weights_file).to eq('weights.yml')
    end

    it 'assigns file to weights_file when parameter -weights-file is given' do
      options = Plasper::Options.new %w(--weights-file weights.yml)
      expect(options.weights_file).to eq('weights.yml')
    end

    it 'assigns file to output_file when parameter -o is given' do
      options = Plasper::Options.new %w(-o weights.yml)
      expect(options.output_file).to eq('weights.yml')
    end

    it 'assigns file to output_file when parameter --output-file is given' do
      options = Plasper::Options.new %w(--output-file weights.yml)
      expect(options.output_file).to eq('weights.yml')
    end
  end

  context 'choosing action' do
    it 'accepts talk action'
    it 'accepts chat action'
    it 'accepts dump action'
  end
end
