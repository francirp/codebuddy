require 'spec_helper'
require_relative '../../lib/open_ai/retrieve_run'

RSpec.describe OpenAI::CreateMessage do
  let(:run_id) { "run_7mv2VpvzcZtK6CicKxsCutEy" }
  subject(:retrieve_run_service) { OpenAI::RetrieveRun.new(run_id) }

  describe '#call' do
    it 'calls the API' do
      # TODO
    end
  end
end