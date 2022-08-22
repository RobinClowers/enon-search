require 'fileutils'
require 'benchmark'
require './index'
require './app_logger'

class Search
  def self.search
    term = ENV.fetch('QUERY_TERM', 'test').downcase
    Search.new.search(term)
  end

  def initialize(output = STDOUT)
    @output = output
    @index = Index.new
  end

  def search(term)
    first = true
    result = @index.search(term) do |result|
      if first
        log result.match(/^From:.*$/i)
        log result.match(/^To:.*$/i)
        log result.match(/^Date:.*$/i)
        log
        log result.gsub(/\A.*?\R\R/m, '')[0..200]
        log '...' if result.length > 200
        first = false
      end
    end
    log
    log "Search term `#{term}` returned #{result.count} documents"
  end

  private

  def log(message = nil)
    @output.write(message) if message
    @output.write("\n")
  end
end
