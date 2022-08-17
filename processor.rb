require 'find'
require 'fileutils'
require './constants'
require './index'

AllowChars = /[^0-9A-Za-z\s]/

class Processor
  def self.process(source_dir, max_files: :infinity)
    new(source_dir, max_files: max_files).process
  end

  def initialize(source_dir, max_files:)
    @source_dir = source_dir
    @max_files = max_files
    @files = []
    @file_words = {}
    @buckets = {}
  end

  def process
    FileUtils.rm_rf(ProcessedDataPath)
    @index = Index.new(ProcessedDataPath)
    puts 'Walking source directory'
    walk_directory
    puts "Discovered #{@files.length} files"
    @files.each_with_index do |path, i|
      process_file(path, i)
    rescue StandardError => e
      puts e
      puts e.backtrace
      puts path
      exit(1)
    end
    puts "indexing #{@file_words.length} files"
    @index.write(@file_words)
  end

  def process_file(path, index)
    puts("#{@files.length - index} files remaining") if index % 10_000 == 0
    contents = IO.read(path).force_encoding('ISO-8859-1').encode('utf-8', replace: '?')
    @file_words[contents.hash.to_s] = contents.gsub(AllowChars, '').split.flatten
    File.write(File.join(ObjectsPath, contents.hash.to_s), contents)
  end

  def walk_directory
    Find.find(@source_dir) do |path|
      return if @max_files != :infinity && @files.length > @max_files

      name = File.basename(path)
      if name[0] == '.'
        Find.prune
      elsif File.file?(path)
        @files << path
      end
    end
  end
end

Processor.process('./source_data', max_files: 100)
