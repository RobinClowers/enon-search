require_relative '../indexer'
require_relative '../index_file'

describe Indexer do
  subject(:indexer) { Indexer.new(options) }
  let(:options) { IndexerOptions.new(path: './spec/fixtures/source_data', max_files: 1) }

  before(:all) do
    AppLogger = Logger.new(nil)
  end

  describe '#index' do
    let(:prefix) { 'ou' }
    let(:word) { 'our' }

    before do
      IndexFile.base_path = './test_index'
      Index.delete_index
      Index.create_index
    end

    it 'creates an prefix index', :focus do
      indexer.index

      expect(IndexFile.prefix_lines(prefix)).to eql [word]
    end

    it 'creates word index', :focus do
      indexer.index
      hash = IndexFile.word_lines(word).first
      object = IndexFile.object(hash)

      expect(object).to include word
    end
  end
end
