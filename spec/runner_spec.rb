require 'plasper'

RSpec.describe Plasper::Runner do
  describe '#initialize' do
    it 'assigns options with given ARGV' do
      expect(Plasper::Options).to receive(:new).with([]).and_call_original
      Plasper::Runner.new []
    end

    it 'assigns options to @options' do
      runner = Plasper::Runner.new []
      expect(runner.instance_variable_get(:@options)).to be_a(Plasper::Options)
    end

    it 'assigns instance of Plasper to @plasper' do
      runner = Plasper::Runner.new []
      expect(runner.instance_variable_get(:@plasper)).to be_a(Plasper::Plasper)
    end
  end

  describe '#run' do
    before(:each) { allow_any_instance_of(Plasper::Runner).to receive(:dump) }

    it 'prepares input weights if file path is given' do
      runner = Plasper::Runner.new %w(-w weights.yml)
      expect(runner).to receive(:import_weights)
      runner.run
    end

    it 'prepares input text if file path is given' do
      runner = Plasper::Runner.new %w(-t text.txt)
      expect(runner).to receive(:import_text)
      runner.run
    end

    it 'exports weights to output file if file path is given' do
      runner = Plasper::Runner.new %w(-o weights.yml)
      expect(runner).to receive(:export_weights)
      runner.run
    end

    it 'runs action' do
      runner = Plasper::Runner.new []
      expect(runner).to receive(:send).with(:dump)
      runner.run
    end
  end
end