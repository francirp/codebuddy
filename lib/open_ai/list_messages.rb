module OpenAI
  class ListMessages
    attr_reader :client, :thread_id, :response

    def initialize
      @client = Client.new
      @thread_id = ConfigManager.new.thread_id
    end

    def call
      @response = client.get("/v1/threads/#{thread_id}/messages")
    end

    def recent_assistant_messages
      assistant_messages = []
      response["data"].each do |item|
        break if item['role'] == 'user'
        assistant_messages << item
      end
      assistant_messages.reverse
    end

    def print_unread_messages
      recent_assistant_messages.each do |hash|
        text = hash.dig("content", 0, "text", "value")
        puts text
      end
    end

    def id
      response["id"]
    end
  end
end
