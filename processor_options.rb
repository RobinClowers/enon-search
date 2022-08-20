require 'optparse'

ProcessorOptions = Struct.new(:verbose, :max_files, :chunk_size, :path, :output_path) do
  def initialize(args = {})
    super(args)
    # Seems like the args[sym] part should be automatic?
    self.verbose = args[:verbose] || false
    self.path = args[:path] || ENV.fetch('SOURCE_PATH', './source_data')
    self.output_path = args[:output_path] || ENV.fetch('PROCESSED_DATA_PATH', './processed_data')
    self.max_files = args[:max_files] || ENV.fetch('MAX_FILES', 10_00).to_i
    self.chunk_size = args[:chunk_size] || ENV.fetch('CHUNK_SIZE', 100).to_i
  end

  def self.parse!(args)
    options = ProcessorOptions.new
    OptionParser.new(args) do |opts|
      opts.banner = 'Usage: example.rb [options]'

      opts.on('-v', '--verbose', 'Run verbosely') do |v|
        options[:verbose] = v
      end

      opts.on('-m', '--max-files FILES', Numeric, 'Maximum files to process') do |m|
        options[:max_files] = m
      end

      opts.on('-c', '--chunk-size SIZE', Numeric, 'How many files to load into memory at a time') do |c|
        options[:chunk_size] = c
      end

      opts.on('-p PATH', '--path PATH', 'Path to source data to be indexed') do |path|
        options[:path] = path
      end

      opts.on('-o PATH', '--out_path PATH', 'Path to new index') do |path|
        options[:output_path] = path
      end

      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end
    end.parse!

    options
  end
end
