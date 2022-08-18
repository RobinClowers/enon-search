require 'find'
require 'fileutils'
require './constants'
require './index'

AllowChars = /[^0-9A-Za-z\s]/
ChunkSize = 1000

class Processor
  def self.process(source_dir, max_files: :infinity)
    new(source_dir, max_files: max_files).process
  end

  def initialize(source_dir, max_files:)
    @source_dir = source_dir
    @max_files = max_files
    @index = Index.new(ProcessedDataPath)
    @total_file_count = 0
    @files = []
    @file_words = {}
  end

  def process
    puts 'Removing data directory'
    FileUtils.rm_rf(ProcessedDataPath)
    @index.create_index
    puts 'Walking source directory'
    walk_directory
    puts "Discovered #{@files.length} files"
    @start_time = Time.now
    slice = 1
    @files.each_slice(ChunkSize) do |chunk|
      puts "Processing #{chunk.length} files"
      chunk.each do |path|
        process_file(path)
      rescue StandardError => e
        puts "failed on #{path}"
        raise e
      end
      puts "Indexing #{chunk.length} files"
      @index.write(@file_words)
      @file_words = {}
      puts "Chunk #{slice} complete in #{Time.now - @start_time}s"
      puts("#{remaining_files(slice)} files remaining")
      slice += 1
    end
    puts 'Done'
  rescue StandardError => e
    puts e.class
    puts e.to_s[0..100]
    puts e.backtrace
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
    File.write(File.join(ObjectsPath, contents.hash.to_s), contents)
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

Processor.process('./source_data', max_files: ENV.fetch('MAX_FILES', 100).to_i)
