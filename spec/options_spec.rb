require 'plasper'

RSpec.describe Plasper::Options do
  context 'paths to files' do
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
    it 'assigns action after options' do
      options = Plasper::Options.new ['talk']
      expect(options.action).to eq('talk')
    end

    it 'assigns dump as default action' do
      options = Plasper::Options.new []
      expect(options.action).to eq(Plasper::Options::DEFAULT_ACTION)
    end

    it 'falls back to default action when action is invalid' do
      options = Plasper::Options.new ['what?']
      expect(options.action).to eq(Plasper::Options::DEFAULT_ACTION)
    end
  end
end
