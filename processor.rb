require 'find'
require './app_logger'
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
    @files.each_slice(ChunkSize) do |chunk|
      AppLogger.info "Processing #{chunk.length} files"
      start_time = Time.now
      chunk.each do |path|
        process_file(path)
      rescue StandardError => e
        AppLogger.error "failed on #{path}"
        raise e
      end
      AppLogger.info "  done in #{Time.now - start_time}s"
      AppLogger.info "Indexing #{chunk.length} files"
      start_time = Time.now
      @index.write(@file_words)
      AppLogger.info "  done in #{Time.now - start_time}s"
      @file_words = {}
      AppLogger.info "Chunk #{slice} complete in #{Time.now - start_time}s"
      AppLogger.info("#{remaining_files(slice)} files remaining")
      slice += 1
    end
    AppLogger.info 'Done'
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
