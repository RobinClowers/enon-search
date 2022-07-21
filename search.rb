require 'fileutils'
require 'benchmark'

class Search
  def initialize(data_path)
    @data_path = data_path
  end

  def search(term)
    term.downcase!
    words = File.readlines(File.join(@data_path, term[0]))
    words.select { |word| word.start_with?(term) }
  end

  def search2(term)
    term.downcase!
    words = File.readlines(File.join(@data_path, term[0..1]))
    words.select { |word| word.start_with?(term) }
  end
end

single_search = Search.new('./temp')
prefix_search = Search.new('./processed_data')

Benchmark.bm do |x|
  x.report('single letter') { 10.times { single_search.search('te') } }
  x.report('two letter') { 10.times { prefix_search.search2('te') } }
end
