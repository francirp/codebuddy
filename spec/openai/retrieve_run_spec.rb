require 'spec_helper'
require_relative '../../lib/open_ai/retrieve_run'

RSpec.describe OpenAI::RetrieveRun do
  let(:run_id) { "run_7mv2VpvzcZtK6CicKxsCutEy" }
  subject(:retrieve_run_service) { OpenAI::RetrieveRun.new(run_id) }

  describe '#call' do
    it 'retrieves the status of a run from the API' do
      run_status = {"id" => run_id, "object" => "run", "status" => "succeeded"}
      allow(retrieve_run_service).to receive(:call).and_return(run_status)
      expect(retrieve_run_service.call).to eq(run_status)
    end
  end
end
