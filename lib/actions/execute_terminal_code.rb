module Actions
  class ExecuteTerminalCode < Action
    def call
      operations = params["ordered_terminal_operations"]
      output = operations.map do |operation|
        CommandExecutor.new.execute(operation)
      end.join("\n")
    end
  end
end