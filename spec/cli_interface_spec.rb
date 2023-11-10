require 'spec_helper'
require_relative '../lib/cli_interface'

RSpec.describe CLIInterface do
  subject(:cli_interface) { CLIInterface.new }
  let(:test_api_key) { 'test_api_key' }
  let(:test_path) { 'spec/fixtures' }
  let(:test_query) { 'What is Ruby?' }

  before do
    allow_any_instance_of(ConfigManager).to receive(:load_config).and_return({})
    allow_any_instance_of(ConfigManager).to receive(:save_config).and_return(true)
    allow_any_instance_of(ConfigManager).to receive(:save_context).and_return(true)
  end

  describe '#set_openai_key' do
    it 'updates the OpenAI API key' do
      expect { cli_interface.set_openai_key(test_api_key) }
        .to output(/OpenAI API key updated/).to_stdout
    end
  end

  describe '#add' do    
    it 'adds a path to the context' do
      allow_any_instance_of(ContextManager).to receive(:add_path)
      result = cli_interface.add(test_path)
      expect(result).to eq(true)
    end
  end

  describe '#remove' do
    it 'removes a path from the context' do
      allow_any_instance_of(ContextManager).to receive(:remove_path)
      result = cli_interface.remove(test_path)
      expect(result).to eq(true)
    end
  end

  describe '#view' do
    context 'when there are no context paths' do
      it 'informs that no context paths are set' do
        expect { cli_interface.view }.to output("No context paths set.\n").to_stdout
      end
    end

    context 'when there are context paths' do      
      it 'checks if output includes a specific string' do
        allow_any_instance_of(ContextManager).to receive(:context_paths).and_return(['/example/path'])
        specific_string = 'Current context paths:'
        expect { cli_interface.view }.to output(/#{specific_string}/).to_stdout
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
end
