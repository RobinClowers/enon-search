module IndexFile
  def self.object_path(hash)
    File.join(ObjectsPath, hash)
  end

  def self.write_words(appended_words)
    # start_time = Time.now
    puts "  appending to #{appended_words.length} prefixes"
    appended_words.each do |prefix, words|
      file = File.new(prefix_path(prefix), 'a')
      file.write(words.uniq.join)
      # puts "#{words.uniq.length} words complete in #{Time.now - start_time}s"
    ensure
      file&.close
    end
  end

  def self.write_hashes(hashes)
    puts "  appending to #{hashes.length} words"
    # start_time = Time.now
    hashes.each do |word, hashes|
      file = File.new(word_path(word), 'a')
      file.write(hashes.uniq.join)
      # puts "#{hashes.uniq.length} hashes complete in #{Time.now - start_time}s"
    ensure
      file&.close
    end
  end

  def self.prefix_path(prefix)
    File.join(IndiciesPath, prefix)
  end

  def self.prefix_lines(prefix)
    read_file_lines?(prefix_path(prefix))
  end

  def self.word_path(word)
    File.join(WordsPath, word[0..20])
  end

  def self.word_lines(word)
    read_file_lines?(word_path(word))
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
