module OpenAI
  class CreateMessage
    attr_reader :client, :thread_id, :response, :content

    def initialize(content)
      @client = Client.new
      @thread_id = ConfigManager.new.thread_id
      @content = content
    end

    def call
      @response = client.post("/v1/threads/#{thread_id}/messages", { body: data })
    end

    def id
      response["id"]
    end

    private

    def data
      { 
        role: "user", 
        content: content
      }.to_json
    end
  end
end
