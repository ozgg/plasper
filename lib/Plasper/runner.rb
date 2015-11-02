require_relative 'plasper'
require_relative 'options'

module Plasper
  class Runner
    def initialize(argv)
      @plasper = Plasper.new
      @options = Options.new(argv)
    end

    def run
      import_weights @options.weights_file unless @options.weights_file.nil?
      import_text @options.text_file unless @options.text_file.nil?
      action = @options.action.to_sym
      send action if respond_to? action, true
      export_weights @options.output_file unless @options.output_file.nil?
    end

    private

    def dump
      dump_weights STDOUT
    end

    def talk
      puts @plasper.passage
    end

    def import_weights(path)
      if File.exists? path
        type, category = nil, nil
        File.open(path).read.each_line do |line|
          if line =~ /\A\S+:\s*\z/
            type = line.gsub(/[:\s]/, '').to_sym
          elsif line =~ /\A  \S+:\s*\z/
            category = line.gsub(/[\s:]/, '')
            category = category.to_sym if %w(word sentence letter).include? category
          elsif line =~ /\A    \S*?:\s+\d+\s*\z/
            if type.is_a?(Symbol) && !category.nil?
              item, weight = line.strip.split(':')
              @plasper.add_weight type, category, (item == '' ? nil : item), Integer(weight)
            end
          end
        end
      end
    end

    def import_text(path)
      if File.exists? path
        File.open(path).read.each_line { |line| @plasper << line }
      end
    end

    def export_weights(path)
      File.open(path, 'w') { |file| dump_weights file }
    end

    def dump_weights(output)
      @plasper.weights.each do |type, type_data|
        output.puts "#{type}:"
        type_data.each do |category, item_data|
          output.puts "  #{category}:"
          item_data.each { |item, data| output.puts "    #{item}: #{data}" }
        end
      end
    end
  end
end