module OpenAI
  class Client
    include HTTParty
    base_uri 'https://api.openai.com'

    attr_reader :api_key

    def initialize
      @api_key = ConfigManager.new.openai_key
      raise "Please add your OpenAI Key: codebuddy set_openai_key your-key-here" if api_key.nil?
    end

    def get(endpoint, options = {})
      self.class.get(endpoint, options.merge(default_options))
    end

    def post(endpoint, options = {})
      self.class.post(endpoint, options.merge(default_options))
    end

    private

    def default_options
      {
        headers: {
          'Authorization' => "Bearer #{api_key}",
          'Content-Type' => 'application/json',
          'OpenAI-Beta' => 'assistants=v1',
        }
      }
    end
  end
end