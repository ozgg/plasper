require 'plasper'

RSpec.describe Plasper::Runner do
  describe '#initialize' do
    before(:each) { allow_any_instance_of(Plasper::Runner).to receive(:dump) }

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

    it 'prepares input weights if file path is given' do
      expect_any_instance_of(Plasper::Runner).to receive(:import_weights)
      Plasper::Runner.new %w(-w weights.yml)
    end

    it 'prepares input text if file path is given' do
      expect_any_instance_of(Plasper::Runner).to receive(:import_text)
      Plasper::Runner.new %w(-t text.txt)
    end

    it 'exports weights to output file if file path is given' do
      expect_any_instance_of(Plasper::Runner).to receive(:export_weights)
      Plasper::Runner.new %w(-o weights.yml)
    end

    it 'runs action' do
      expect_any_instance_of(Plasper::Runner).to receive(:send).with(:dump)
      Plasper::Runner.new []
    end
  end
end