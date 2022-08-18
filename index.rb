require 'fileutils'
require './constants'

# Fragment index file names are a prefix of a word
# They contain hashes of objects containing the word separate by newlines
#
# Word index file names are single words
# They contain hashes separated by newlines
#
#
# by opening the word file based on the fragment index,
# we can get all the hashes that contain the word
class Index
  def initialize(path)
    @path = path
  end

  def create_index
    FileUtils.mkdir_p(objects_base_path)
    FileUtils.mkdir_p(words_base_path)
  end

  def write(file_words)
    file_words.each_with_index do |entry, _i|
      hash, words = entry
      words.sort.each do |word|
        word.downcase!
        append_word(word[0..1], word)
        append_word_hash(word, hash)
      end
    end
  end

  def search(term)
    prefix = term[0..1]
    path = prefix_path(prefix)
    raise 'Term not found' unless File.exist?(path)

    words = read_file_lines?(path).filter { |w| w.start_with?(term) }
    hashes = words.uniq.flat_map { |word| read_file_lines?(word_path(word)) }.uniq
    puts "found #{hashes.length} hashes"
    hashes.map { |hash| File.read(object_path(hash)) }
  end

  private

  def object_path(hash)
    File.join(objects_base_path, hash)
  end

  def objects_base_path
    @objects_base_path ||= File.join(@path, 'objects')
  end

  def append_word(prefix, word)
    File.new(prefix_path(prefix), 'a').write("#{word}\n")
  end

  def append_word_hash(word, hash)
    File.new(word_path(word), 'a').write("#{hash}\n")
  end

  def prefix_path(prefix)
    File.join(@path, 'indicies', prefix)
  end

  def prefix_lines(prefix)
    read_file_lines?(prefix_path(prefix))
  end

  def word_path(word)
    File.join(words_base_path, word)
  end

  def words_base_path
    @words_base_path ||= File.join(@path, 'indicies', 'words')
  end

  def word_lines(word)
    read_file_lines?(word_path(word))
  end

  def read_file_lines?(path)
    if File.exist?(path)
      File.read(path).split
    else
      []
    end
  end
end
