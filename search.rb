require 'fileutils'
require 'benchmark'
require './index'
require './app_logger'

class Search
  attr_reader :output

  def self.search
    term = ENV.fetch('QUERY_TERM', 'test').downcase
    Search.new.search(term)
  end

  def initialize(output = STDOUT)
    @output = output
    @index = Index.new
  end

  def search(term)
    result = @index.search(term)
    unless result.empty?
      log result.first.match(/^From:.*$/i)
      log result.first.match(/^To:.*$/i)
      log result.first.match(/^Date:.*$/i)
      log
      log result.first.gsub(/\A.*?\R\R/m, '')[0..200]
      log '...' if result.first.length > 200
    end
    log
    log "Search term `#{term}` returned #{result.count} documents"
  end

  private

  def log(message = nil)
    output.write(message) if message
    output.write("\n")
  end
end
