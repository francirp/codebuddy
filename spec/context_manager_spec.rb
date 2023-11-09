require 'spec_helper'
require_relative '../lib/context_manager'

RSpec.describe ContextManager do
  subject(:context_manager) { ContextManager.new }

  describe '#add_path' do
    context 'when adding a valid file path' do
      let(:file_path) { 'spec/fixtures/valid_file.rb' }

      it 'adds the file to the context' do
        expect(context_manager.add_path(file_path)).to include("added to context")
      end
    end

    context 'when adding an invalid file path' do
      it 'returns an error message' do
        expect(context_manager.add_path('invalid/path')).to eq("Path does not exist.")
      end
    end

    # Add more contexts for different scenarios like token limit exceeded, unsupported file types, etc.
  end

  describe '#remove_path' do
    let(:file_path) { 'spec/fixtures/valid_file.rb' }

    before { context_manager.add_path(file_path) }

    context 'when removing a valid path' do
      it 'removes the path from the context' do
        expect(context_manager.remove_path(file_path)).to include("removed from context")
      end
    end

    context 'when removing an invalid path' do
      it 'returns an error message' do
        expect(context_manager.remove_path('invalid/path')).to eq("Path not found in context.")
      end
    end
  end

  describe '#current_context' do
    let(:file_path) { 'spec/fixtures/valid_file.rb' }

    before { context_manager.add_path(file_path) }

    it 'returns the current context' do
      expect(context_manager.current_context).to include(file_path)
    end
  end

  # Add tests for other methods like #exceeds_token_limit?, #calculate_char_count, etc.
end
