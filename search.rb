require 'fileutils'
require 'benchmark'
require './constants'

class Search
  def initialize(data_path)
    @data_path = data_path
  end

  def search(term)
    term.downcase!
    words = File.readlines(File.join(@data_path, term[0..1]))
    words.select { |word| word.start_with?(term) }
  end
end

puts Search.new(ProcessedDataDir).search('illegal')
