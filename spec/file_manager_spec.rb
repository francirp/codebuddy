require 'spec_helper'
require_relative '../lib/file_manager'

RSpec.describe FileManager do
  subject(:file_manager) { FileManager.new }
  let(:file_path) { 'spec/fixtures/test_file.txt' }
  let(:content) { "Hello, World!" }

  describe '#create_file' do
    after { File.delete(file_path) if File.exist?(file_path) }

    context 'when creating a new file' do
      it 'creates the file and returns a success message' do
        expect(file_manager.create_file(file_path, content)).to eq("File created: #{file_path}")
        expect(File.exist?(file_path)).to be true
        expect(File.read(file_path)).to eq(content)
      end
    end
  end

  describe '#update_file' do
    context 'when the file exists' do
      before { File.write(file_path, "Old Content") }
      after { File.delete(file_path) }

      it 'updates the file content and returns a success message' do
        new_content = "New Content"
        expect(file_manager.update_file(file_path, new_content)).to eq("File updated: #{file_path}")
        expect(File.read(file_path)).to eq(new_content)
      end
    end

    context 'when the file does not exist' do
      it 'returns an error message' do
        expect(file_manager.update_file('nonexistent_file.txt', content)).to eq("File does not exist: nonexistent_file.txt")
      end
    end
  end

  describe '#delete_file' do
    context 'when the file exists' do
      before { File.write(file_path, content) }

      it 'deletes the file and returns a success message' do
        expect(file_manager.delete_file(file_path)).to eq("File deleted: #{file_path}")
        expect(File.exist?(file_path)).to be false
      end
    end

    context 'when the file does not exist' do
      it 'returns an error message' do
        expect(file_manager.delete_file('nonexistent_file.txt')).to eq("File does not exist: nonexistent_file.txt")
      end
    end
  end
end
