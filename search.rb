require 'fileutils'
require 'benchmark'
require './index'
require './constants'

class Search
  def initialize(data_path)
    @data_path = data_path
    @index = Index.new(data_path)
  end

  def search(term)
    @index.search(term)
  end
end

result = Search.new(ProcessedDataPath).search('are')
puts result
puts "\nReturned #{result.count} documents"
