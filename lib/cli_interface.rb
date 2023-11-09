require 'thor'

class CLIInterface < Thor
  desc "init", "Initialize Jarvis in the current directory"
  def init
    # Initialization code here
    puts "Jarvis initialized."
  end

  desc "add_context DIRECTORY", "Add a directory to Jarvis's context"
  def add_context(directory)
    # Code to add a directory to the context
    puts "#{directory} added to context."
  end

  desc "remove_context DIRECTORY", "Remove a directory from Jarvis's context"
  def remove_context(directory)
    # Code to remove a directory from the context
    puts "#{directory} removed from context."
  end

  desc "ask QUERY", "Send a query to Jarvis"
  def ask(query)
    # Code to send the query to ChatGPT Assistant and display the response
    puts "Query sent: #{query}"
    # Display the response here
  end

  # Additional commands can be added here

  private

  # Private helper methods can be defined here
end
