module OpenAI
  class CreateThread
    attr_reader :client, :response

    def initialize
      @client = Client.new
    end

    def call
      @response = client.post('/v1/threads')
    end

    def id
      response["id"]
    end
  end
end
