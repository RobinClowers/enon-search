require 'fileutils'
require 'benchmark'
require './index'
require './constants'

class Search
  def self.search
    term = ENV.fetch('QUERY_TERM', 'test').downcase
    result = Search.new(ProcessedDataPath).search(term)
    puts result.first unless result.empty?
    puts "\nSearch term `#{term}` returned #{result.count} documents"
  end

  def initialize(data_path)
    @data_path = data_path
    @index = Index.new(data_path)
  end

  def search(term)
    @index.search(term)
  end
end

Search.search
