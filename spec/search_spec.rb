require 'fileutils'
require_relative '../search'

class FakeIO
  attr_reader :messages

  def initialize
    @messages = []
  end

  def write(message = '')
    @messages << message.to_s
  end
end

describe Search do
  subject(:search) { Search.new(output) }
  let(:output) { FakeIO.new }
  let(:messages) { output.messages.join("\n") }

  before(:all) do
    AppLogger = Logger.new(nil)
    IndexFile.base_path = './spec/fixtures/test_index'
  end

  describe '#search' do
    let(:term) { 'our' }

    it 'prints the term and total results' do
      search.search(term)
      expect(messages).to include "Search term `our` returned 1 documents"
    end

    it 'prints the first result header' do
      search.search(term)
      expect(messages).to include "From: phillip.allen@enron.com"
      expect(messages).to include "To: tim.belden@enron.com"
      expect(messages).to include "Date: Mon, 14 May 2001 16:39:00 -0700 (PDT)"
    end
  end
end
