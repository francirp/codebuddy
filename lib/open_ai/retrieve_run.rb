module OpenAI
  class RetrieveRun
    attr_reader :client, :thread_id, :run_id, :response

    def initialize(run_id, thread_id)
      @client = Client.new
      @thread_id = thread_id
      @run_id = run_id
    end

    def call
      puts "polling run..."
      @response = client.get("/v1/threads/#{thread_id}/runs/#{run_id}")
      binding.pry
      puts "run status: #{status}"
      handle_function_calls if requires_action?
      response
    end

    def id
      response_hash["id"]
    end

    def requires_action?
      status == "requires_action"
    end

    def finished?
      status == "completed"
    end    

    def response_hash
      if response["object"] && response["object"] == "list"
        response.dig("data", 0)
      else
        response
      end
    end

    def status
      response_hash.dig("status")
    end

    def handle_function_calls
      array = response_hash.dig("required_action", "submit_tool_outputs", "tool_calls")
      functions = array.find_all { |tool| tool["type"] == "function" } # can be other types of actions besides functions
      tool_output_hashes = functions.map do |function|
        name = function.dig("function", "name")
        action_class_name = name.split('_').map(&:capitalize).join
        action_class = Object.const_get "Actions::#{action_class_name}"
        arguments = function.dig("function", "arguments")
        json = JSON.parse(arguments)
        instance = action_class.new(json)
        output = instance.run

        {
          tool_call_id: function["id"],
          output: output,
        }        
      end

      SubmitToolOutputs.new(thread_id, id, tool_output_hashes).call
    end
  end
end
