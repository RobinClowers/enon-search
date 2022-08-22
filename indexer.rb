require 'find'
require './app_logger'
require './index'
require './indexer_options'

AllowChars = /[^0-9A-Za-z\s]/

class Indexer
  attr_accessor :options

  def self.index(source_dir, max_files: :infinity)
    new(IndexerOptions.new(path: source_dir, max_files: max_files)).index
  end

  def initialize(options)
    @options = options
    @index = Index.new
    @total_file_count = 0
    @files = []
    @file_words = {}
  end

  def index
    AppLogger.warn 'Removing data directory'
    start_time = Time.now
    Index.delete_index
    AppLogger.info "  done in #{Time.now - start_time}s"

    Index.create_index
    AppLogger.info 'Walking source directory'
    start_time = Time.now
    walk_directory
    AppLogger.info "  done in #{Time.now - start_time}s"
    AppLogger.info "  discovered #{@files.length} files"

    start_time = Time.now
    slice = 1
    @files.each_slice(options.chunk_size) do |chunk|
      AppLogger.info "Indexing #{chunk.length} files"
      start_time = Time.now
      chunk.each do |path|
        index_file(path)
      rescue StandardError => e
        AppLogger.error "failed on #{path}"
        raise e
      end
      AppLogger.info "  done in #{Time.now - start_time}s"
      AppLogger.info "Indexing #{chunk.length} files"

      start_time = Time.now
      @index.write(@file_words)
      @file_words = {}
      AppLogger.info "  done in #{Time.now - start_time}s"
      AppLogger.info "Chunk #{slice} complete in #{Time.now - start_time}s"
      AppLogger.info("#{remaining_files(slice)} files remaining")
      slice += 1
    end
    AppLogger.info 'Done'
  end

  private

  def remaining_files(slice)
    if options.chunk_size > @files.length
      @files.length
    else
      @files.length - slice * options.chunk_size
    end
  end

  def index_file(path)
    contents = IO.read(path).force_encoding('ISO-8859-1').encode('utf-8', replace: '?')
    @file_words[contents.hash.to_s] = contents.gsub(AllowChars, '').split.flatten
    File.write(File.join(IndexFile.objects_path, contents.hash.to_s), contents)
  end

  def walk_directory
    Find.find(options.path) do |path|
      return if options.max_files != :infinity && @files.length >= options.max_files

      name = File.basename(path)
      if name[0] == '.'
        Find.prune
      elsif File.file?(path)
        @files << path
      end
    end
  end
end
