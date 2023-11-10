require 'spec_helper'
require_relative '../../lib/open_ai/create_message'

RSpec.describe OpenAI::CreateMessage do
  let(:content) { "Hello, is this working?" }
  subject(:create_message_service) { OpenAI::CreateMessage.new(content) }

  describe '#call' do
    it 'calls the API' do
      # TODO
    end
  end
end
