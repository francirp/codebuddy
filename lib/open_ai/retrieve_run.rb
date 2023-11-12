module OpenAI
  class RetrieveRun
    attr_reader :client, :thread_id, :run_id, :response

    def initialize(run_id)
      @client = Client.new
      @thread_id = ConfigManager.new.thread_id
      @run_id = run_id
    end

    def call
      puts "polling run..."
      @response = client.get("/v1/threads/#{thread_id}/runs/#{run_id}")
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
      outputs = functions.map do |function|
        name = function.dig("function", "name")
        puts "action: #{name}"
        arguments = function.dig("function", "arguments")        
        output = ""
        begin
          case name
          when "multi_tool_use.parallel"
            binding.pry
          when "create_repo_files"
            json = JSON.parse(arguments)
            files = json["files"]
            files.each do |file|
              file_manager.create_file(file["file_path"], file["file_content"])
            end
            output = "success"
          when "get_repo_files"
            json = JSON.parse(arguments)
            files = json["file_paths"]
            puts "sending files: #{files}"
            output = files.map do |file|
              file_manager.get_file(file)
            end.join("\n\n")
          when "replace_repo_files"
            json = JSON.parse(arguments)
            files = json["files"]
            files.each do |file|
              file_manager.replace_file(file["file_path"], file["file_content"])
            end
            output = "success"
          when "update_repo_files"
            puts "updating repo files..."
            json = JSON.parse(arguments)  
            files = json["files"]
            files.each do |file|
              diffs = file["diffs"]
              file_manager.update_file(file["file_path"], diffs)
            end
            output = "success"
          when "delete_repo_files"
            json = JSON.parse(arguments)
            files = json["file_paths"]
            files.each do |file|
              file_manager.delete_file(file)
            end
            output = "success"
          when "execute_terminal_code"
            json = JSON.parse(arguments)
            operations = json["ordered_terminal_operations"]
            output = operations.map do |operation|
              CommandExecutor.new.execute(operation)
            end.join("\n")
          end
        rescue => e
          output = e.message
        end

        {
          tool_call_id: function["id"],
          output: output,
        }
      end

      SubmitToolOutputs.new(id, outputs).call
    end

    def file_manager
      @file_manager ||= FileManager.new
    end
  end
end
