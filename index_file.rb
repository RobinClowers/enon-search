require 'fileutils'
require './app_logger'

module IndexFile
  def self.base_path
    @base_path ||= ENV.fetch('PROCESSED_DATA_PATH', './processed_data')
  end

  def self.base_path=(path)
    @base_path = path
  end

  def self.write_words(appended_words)
    start_time = Time.now
    AppLogger.info "  appending to #{appended_words.length} prefixes"
    appended_words.each do |prefix, words|
      file = File.new(prefix_path(prefix), 'a')
      file.write(words.uniq.join)
      AppLogger.debug "#{words.uniq.length} words complete in #{Time.now - start_time}s"
    ensure
      file&.close
    end
  end

  def self.write_hashes(hashes)
    AppLogger.info "  appending to #{hashes.length} words"
    start_time = Time.now
    hashes.each do |word, hashes|
      file = File.new(word_path(word), 'a')
      file.write(hashes.uniq.join)
      AppLogger.debug "#{hashes.uniq.length} hashes complete in #{Time.now - start_time}s"
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
