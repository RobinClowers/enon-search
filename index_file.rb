require 'fileutils'
require './app_logger'

module IndexFile
  def self.base_path
    @base_path ||= ENV.fetch('PROCESSED_DATA_PATH', './processed_data')
  end

  def self.base_path=(path)
    @base_path = path
  end

  def self.write_words(objects_hash)
    write(objects_hash) { |prefix| prefix_path(prefix) }
  end

  def self.write_hashes(objects_hash)
    write(objects_hash) { |word| word_path(word) }
  end

  # objects_hash - { prefix|word => words[]|hashes[] }
  def self.write(objects_hash, &block)
    raise 'block required for path construction' unless block_given?

    AppLogger.info "  appending to #{objects_hash.length} words"
    start_time = Time.now
    objects_hash.each do |word, lines|
      file = File.new(block.call(word), 'a')
      file.write(lines.uniq.join)
      AppLogger.debug "#{lines.uniq.length} lines written in #{Time.now - start_time}s"
    ensure
      file&.close
    end
  end

  def self.indicies_path
    File.join(@base_path, 'indicies')
  end

  def self.prefix_path(prefix)
    File.join(indicies_path, prefix)
  end

  def self.prefix_lines(prefix)
    read_file_lines?(prefix_path(prefix))
  end

  def self.words_path
    File.join(@base_path, 'words')
  end

  def self.word_path(word)
    File.join(words_path, word[0..20])
  end

  def self.word_lines(word)
    read_file_lines?(word_path(word))
  end

  def self.objects_path
    File.join(@base_path, 'objects')
  end

  def self.object_path(hash)
    File.join(objects_path, hash)
  end

  def self.object(hash)
    File.read(object_path(hash))
  end

  def self.read_file_lines?(path)
    if File.exist?(path)
      File.read(path).split
    else
      []
    end
  end
end
