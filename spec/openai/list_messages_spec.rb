require 'spec_helper'
require_relative '../../lib/open_ai/list_messages'

RSpec.describe OpenAI::ListMessages do
  subject(:list_messages_service) { OpenAI::ListMessages.new }

  describe '#call' do
    it 'retrieves a list of messages from the API' do
      messages = [{"id" => "msg_1"}, {"id" => "msg_2"}]
      allow(list_messages_service).to receive(:call).and_return(messages)
      expect(list_messages_service.call).to eq(messages)
    end
  end
end
