require 'fileutils'
require 'benchmark'
require './index'

class Search
  def self.search
    term = ENV.fetch('QUERY_TERM', 'test').downcase
    result = Search.new.search(term)

    unless result.empty?
      puts result.first.match(/^From:.*$/i)
      puts result.first.match(/^To:.*$/i)
      puts result.first.match(/^Date:.*$/i)
      puts
      puts result.first.gsub(/\A.*?\R\R/m, '')[0..200]
      puts '...' if result.first.length > 200
    end
    puts
    puts "Search term `#{term}` returned #{result.count} documents"
  end

  def initialize(data_path = IndexFile.base_path)
    @data_path = data_path
    @index = Index.new(data_path)
  end

  def search(term)
    @index.search(term)
  end
end

Search.search
