require 'spec_helper'
require_relative '../lib/cli_interface'

RSpec.describe CLIInterface do
  subject(:cli_interface) { CLIInterface.new }
  let(:test_api_key) { 'test_api_key' }
  let(:test_path) { 'spec/fixtures' }
  let(:test_query) { 'What is Ruby?' }

  before do
    allow(cli_interface).to receive(:load_config).and_return({})
    allow(cli_interface).to receive(:save_config)
  end

  describe '#set_openai_key' do
    it 'updates the OpenAI API key' do
      expect { cli_interface.set_openai_key(test_api_key) }
        .to output(/OpenAI API key updated/).to_stdout
    end
  end

  describe '#add' do
    it 'adds a path to the context' do
      expect { cli_interface.add(test_path) }
        .to output(/#{test_path} added to context/).to_stdout
    end
  end

  describe '#remove' do
    it 'removes a directory from the context' do
      expect { cli_interface.remove(test_path) }
        .to output(/#{test_path} removed from context/).to_stdout
    end
  end

  describe '#view_paths' do
    context 'when there are no context paths' do
      it 'informs that no context paths are set' do
        expect { cli_interface.view_paths }.to output("No context paths set.\n").to_stdout
      end
    end

    context 'when there are context paths' do
      let(:path) { 'spec/fixtures' }

      before { cli_interface.add(path) }

      it 'displays the current context paths' do
        expect { cli_interface.view_paths }.to output(/Current context paths:\n#{path}\n/).to_stdout
      end
    end
  end  

  describe '#ask' do
    before do
      allow_any_instance_of(ChatGPTAssistant).to receive(:send_request).with(test_query)
                                                                  .and_return('test_response')
    end

    it 'sends a query and outputs the response' do
      expect { cli_interface.ask(test_query) }
        .to output(/Response:\ntest_response/).to_stdout
    end
  end

  # Additional tests for #init and other methods can be added similarly
end
