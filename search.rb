require 'fileutils'

class Search
  def initialize(data_path)
    @data_path = data_path
  end

  def search(term)
    term.downcase!
    words = File.readlines(File.join(@data_path, term[0]))
    words.select { |word| word.start_with?(term) }
  end
end

puts Search.new('./processed_data').search('te')
