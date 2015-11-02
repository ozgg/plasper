require 'optparse'

module Plasper
  class Options
    attr_reader :text_file, :weights_file, :output_file, :action

    DEFAULT_ACTION = 'dump'
    VALID_ACTIONS  = [DEFAULT_ACTION, 'talk', 'chat']

    # Initialize with CLI arguments
    #
    # @param [Array] argv
    def initialize(argv)
      parse argv
      @action = argv.last
      @action = DEFAULT_ACTION unless VALID_ACTIONS.include? @action
    end

    private

    # Parse given arguments
    #
    # @param [Array] argv
    def parse(argv)
      OptionParser.new do |options|
        usage_and_help options
        assign_text_file options
        assign_weights_file options
        assign_output_file options

        begin
          options.parse argv
        rescue OptionParser::ParseError => error
          STDERR.puts error.message, "\n", options
          exit(-1)
        end
      end
    end

    def assign_text_file(options)
      options.on('-t', '--text-file path', String, 'Path to file with text to analyze') do |path|
        @text_file = path
      end
    end

    def assign_weights_file(options)
      options.on('-w', '--weights-file path', String, 'Path to file with initial weights in YAML format') do |path|
        @weights_file = path
      end
    end

    def assign_output_file(options)
      options.on('-o', '--output-file path', String, 'Path to output file for dumping weights') do |path|
        @output_file = path
      end
    end

    def usage_and_help(options)
      options.banner = 'Usage: plasper [options] action'
      options.on('-h', '--help', 'Show this message') do
        puts options
        exit
      end
    end
  end
end
