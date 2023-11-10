module OpenAI
  class CreateRun
    attr_reader :client, :thread_id, :response, :assistant_id, :model

    def initialize
      @client = Client.new
      @thread_id = ConfigManager.new.thread_id
      @assistant_id = "asst_U1V5mpmhHpmuvEQYU5ZudKJ2" # TODO: make this a config setting, or create the assistant for the user
      @model = "gpt-4-1106-preview" # TODO: make this a config setting
    end

    def call
      @response = client.post("/v1/threads/#{thread_id}/runs", { body: data })
    end

    def id
      response["id"]
    end

    private

    def data
      { 
        assistant_id: assistant_id, 
        model: model,
      }.to_json
    end
  end
end
