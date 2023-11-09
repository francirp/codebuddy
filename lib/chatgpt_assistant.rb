require 'httparty'

class ChatGPTAssistant
  include HTTParty
  base_uri 'https://api.openai.com'

  def initialize(api_key)
    @api_key = api_key
  end

  def send_request(user_input, context)
    # Code to send request to OpenAI API with user input and context
    # Return the response
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    }
  end
end
