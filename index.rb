require 'fileutils'
require './constants'
require './index_file'

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
  def initialize(path = ProcessedDataPath)
    @path = path
    @appended_words = {}
    @appended_hashes = {}
  end

  def create_index
    FileUtils.mkdir_p(IndiciesPath)
    FileUtils.mkdir_p(ObjectsPath)
    FileUtils.mkdir_p(WordsPath)
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

    IndexFile.write_words(@appended_words)
    @appended_words = {}
    IndexFile.write_hashes(@appended_hashes)
    @appended_hashes = {}
  end

  def search(term)
    prefix = term[0..1]
    path = IndexFile.prefix_path(prefix)
    raise 'Term not found' unless File.exist?(path)

    words = IndexFile.read_file_lines?(path).filter { |w| w.start_with?(term) }
    hashes = words.uniq.flat_map do |word|
      IndexFile.word_lines(word)
    end.uniq
    puts "found #{hashes.length} hashes"
    hashes.map { |hash| IndexFile.object(hash) }
  end

  private

  def append_word(prefix, word)
    @appended_words[prefix] ||= []
    @appended_words[prefix] << "#{word}\n"
  end

  def append_word_hash(word, hash)
    @appended_hashes[word] ||= []
    @appended_hashes[word] << "#{hash}\n"
  end
end
