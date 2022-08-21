require 'fileutils'
require './index_file'
require './app_logger'

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
  def initialize(path = IndexFile.base_path)
    @path = path
    @appended_words = {}
    @appended_hashes = {}
  end

  def self.delete_index
    FileUtils.rm_rf(IndexFile.base_path)
  end

  def self.create_index
    FileUtils.mkdir_p(IndexFile.prefixes_path)
    FileUtils.mkdir_p(IndexFile.objects_path)
    FileUtils.mkdir_p(IndexFile.words_path)
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
    AppLogger.info "found #{hashes.length} hashes"
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
