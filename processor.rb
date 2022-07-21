require 'find'
require 'fileutils'

AllowChars = /[^0-9A-Za-z\s]/

class Processor
  def self.process(source_dir, target_dir)
    new(source_dir, target_dir).process
  end

  def initialize(source_dir, target_dir)
    @source_dir = source_dir
    @target_dir = target_dir
    @files = []
    @words = []
    @buckets = {}
  end

  def process
    puts 'Walking source directory'
    walk_directory
    puts "Discovered #{@files.length} files"
    @files.each_with_index do |path, i|
      # puts i % 10
      puts("#{@files.length - i} files remaining") if i % 10_000 == 0
      contents = IO.read(path).force_encoding('ISO-8859-1').encode('utf-8', replace: '?')
      @words.concat(contents.gsub(AllowChars, '').split.flatten)
    rescue StandardError => e
      p e
      puts path
      exit(1)
    end
    puts "Bucketing #{@words.length} words"
    bucket_words
    puts "Writing #{@buckets.length} buckets"
    write_buckets
  end

  def walk_directory
    Find.find(@source_dir) do |path|
      name = File.basename(path)
      if name[0] == '.'
        Find.prune
      elsif File.file?(path)
        @files << path
      end
    end
  end

  def bucket_words
    @words.sort.each_with_index do |word, i|
      puts "#{@words.length - i} remaining" if i % 1_000_000 == 0
      word.downcase!
      prefix = word[0..1]
      @buckets[prefix] ||= []
      @buckets[prefix] << word
    end
  end

  def write_buckets
    FileUtils.rm_rf(@target_dir)
    FileUtils.mkdir_p(@target_dir)
    @buckets.each do |letter, words|
      File.write(File.join(@target_dir, letter), words.join("\n"))
    end
  end
end

Processor.process('./source_data', './processed_data')
