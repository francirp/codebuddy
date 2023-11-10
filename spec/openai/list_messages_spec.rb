require 'spec_helper'
require_relative '../../lib/open_ai/list_messages'

RSpec.describe OpenAI::ListMessages do
  subject(:retrieve_run_service) { OpenAI::ListMessages.new }

  describe '#call' do
    it 'calls the API' do      
      # TODO
    end
  end
end
