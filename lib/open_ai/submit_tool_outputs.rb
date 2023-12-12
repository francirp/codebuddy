module OpenAI
  class SubmitToolOutputs
    attr_reader :client, :thread_id, :run_id, :tool_id, :tool_outputs, :response

    def initialize(thread_id, run_id, tool_outputs)
      @client = Client.new
      @run_id = run_id
      @thread_id = thread_id
      @tool_outputs = tool_outputs
    end

    def call
      @response = client.post("/v1/threads/#{thread_id}/runs/#{run_id}/submit_tool_outputs", { body: data })
    end

    def id
      response["id"]
    end

    private

    def data
      { 
        tool_outputs: tool_outputs,
      }.to_json
    end
  end
end
