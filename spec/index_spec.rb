require 'fileutils'
require_relative '../index'

describe Index do
  subject(:index) { Index.new(test_path) }
  let!(:orig_path) { IndexFile.base_path }
  let(:test_path) { File.join('./processed_data_test') }
  let(:indicies_path) { File.join(test_path, 'indicies') }

  before(:all) do
    AppLogger = Logger.new(nil)
  end

  before do
    IndexFile.base_path = test_path
  end

  after do
    IndexFile.base_path = orig_path
  end

  describe '#write' do
    let(:prefix) { 'ar' }
    let(:word) { 'are' }
    let(:prefix_path) { File.join(indicies_path, prefix) }
    let(:word_path) { File.join(test_path, 'words', word) }
    let(:file_words) do
      { 123 => [word] }
    end

    before do
      FileUtils.rm_rf(test_path)
      FileUtils.mkdir_p(indicies_path)
      FileUtils.mkdir_p(File.join(test_path, 'words'))
    end

    it 'writes a new prefix file if needed' do
      index.write(file_words)
      expect(File.exists?(prefix_path)).to be true
      expect(File.read(prefix_path).split).to eql [
        'are',
      ]
    end

    it 'appends to an existing prefix file if it exists' do
      File.write(prefix_path, "art\n")
      index.write(file_words)
      expect(File.exists?(prefix_path)).to be true
      expect(File.read(prefix_path).split).to eql [
        'art',
        'are',
      ]
    end

    it 'writes a new word file if needed' do
      index.write(file_words)
      expect(File.exists?(word_path)).to be true
      expect(File.read(word_path).split).to eql [
        '123',
      ]
    end

    it 'appends to an existing word file if it exists' do
      File.write(word_path, "456\n")
      index.write(file_words)
      expect(File.exists?(word_path)).to be true
      expect(File.read(word_path).split).to eql [
        '456',
        '123',
      ]
    end
  end
end
