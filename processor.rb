require 'find'
require './index'
require './processor_options'

AllowChars = /[^0-9A-Za-z\s]/
ChunkSize = ENV.fetch('CHUNK_SIZE', 100).to_i

class Processor
  def self.process(source_dir, max_files: :infinity)
    new(ProcessorOptions.new(path: source_dir, max_files: max_files)).process
  end

  def initialize(options)
    @source_dir = options.path
    @max_files = options.max_files
    @verbose = options.verbose
    @index = Index.new
    @total_file_count = 0
    @files = []
    @file_words = {}
  end

  def process
    puts 'Removing data directory'
    start_time = Time.now
    Index.delete_index
    puts "  done in #{Time.now - start_time}s"
    Index.create_index
    puts 'Walking source directory'
    start_time = Time.now
    walk_directory
    puts "  done in #{Time.now - start_time}s"
    puts "  discovered #{@files.length} files"
    start_time = Time.now
    slice = 1
    @files.each_slice(ChunkSize) do |chunk|
      puts "Processing #{chunk.length} files"
      start_time = Time.now
      chunk.each do |path|
        process_file(path)
      rescue StandardError => e
        puts "failed on #{path}"
        raise e
      end
      puts "  done in #{Time.now - start_time}s"
      puts "Indexing #{chunk.length} files"
      start_time = Time.now
      @index.write(@file_words)
      puts "  done in #{Time.now - start_time}s"
      @file_words = {}
      puts "Chunk #{slice} complete in #{Time.now - start_time}s"
      puts("#{remaining_files(slice)} files remaining")
      slice += 1
    end
    puts 'Done'
  end

  private

  def remaining_files(slice)
    if ChunkSize > @files.length
      @files.length
    else
      @files.length - slice * ChunkSize
    end
  end

  def process_file(path)
    contents = IO.read(path).force_encoding('ISO-8859-1').encode('utf-8', replace: '?')
    @file_words[contents.hash.to_s] = contents.gsub(AllowChars, '').split.flatten
    File.write(File.join(IndexFile.objects_path, contents.hash.to_s), contents)
  end

  def walk_directory
    Find.find(@source_dir) do |path|
      return if @max_files != :infinity && @files.length >= @max_files

      name = File.basename(path)
      if name[0] == '.'
        Find.prune
      elsif File.file?(path)
        @files << path
      end
    end
  end
end
