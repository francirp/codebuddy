class CommandExecutor
  def execute(command)
    puts "About to execute: '#{command}'"
    puts "Do you want to proceed? [y/n]"
    user_input = $stdin.gets.strip.downcase

    unless user_input == 'y'
      return "Command execution cancelled by user."
    end

    begin
      output = `#{command} 2>&1` # Captures both stdout and stderr
      puts "Command executed successfully:\n#{output}" # Print the output to stdout
      "Command executed successfully:\n#{output}"
    rescue => e
      "Error executing command: #{e.message}"
    end
  end
end
