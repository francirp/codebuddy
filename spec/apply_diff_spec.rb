require 'rspec'
require_relative '../lib/apply_diff'

RSpec.describe ApplyDiff do
  describe '#call' do
    let(:file_path) { 'spec/fixtures/diff_example.rb' }
    let(:original_content) {
      <<~RUBY
        class ExampleClass
          def initialize(items)
            @items = items
          end

          def sum_items
            sum = 0
            @items.each { |item| sum += item }
            sum
          end
        end
      RUBY
    }
    let(:expected_content) {
      <<~RUBY
        class ExampleClass
          attr_reader :items
          def initialize(items)
            @items = items
          end

          def sum_items
            @items.sum
          end
        end
      RUBY
    }
    let(:json_payload) {
      {
        "file_path": file_path,
        "diff_payload": [
          {
            "action": "add",
            "line": "  attr_reader :items",
            "line_number": 2
          },
          {
            "action": "replace",
            "line_number": 7,
            "line": "    @items.sum"
          },
          {
            "action": "remove",
            "line_number": 8
          },
          {
            "action": "remove",
            "line_number": 9
          }
        ]
      }.to_json
    }    

    before do
      File.write(file_path, original_content)
      ApplyDiff.new(json_payload).call
    end

    after do
      File.delete(file_path) if File.exist?(file_path)
    end

    it 'correctly applies diff to the file' do
      expect(File.read(file_path)).to eq(expected_content)
    end
  end
end
