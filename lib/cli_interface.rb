require 'thor'
require 'json'
require_relative 'context_manager'
require_relative 'chat_gpt_assistant'

class CLIInterface < Thor
  CONFIG_FILE = File.join(Dir.home, '.codebuddy_config.json')

  def initialize(*args)
    super
    @context_manager = ContextManager.new
    @config = load_config
    @chat_gpt_assistant = ChatGPTAssistant.new(api_key: @config['openai_key'])
  end

  desc "init", "Initialize Codebuddy in the current directory"
  def init
    puts "Initializing Codebuddy..."
    # Perform initialization steps
    puts "Codebuddy initialized."
  end

  desc "set_openai_key KEY", "Set your OpenAI API key"
  def set_openai_key(key)
    @config['openai_key'] = key
    save_config
    puts "OpenAI API key updated."
  end

  desc "add_context DIRECTORY", "Add a directory to Codebuddy's context"
  def add_context(directory)
    @context_manager.add_directory(directory)
    puts "#{directory} added to context."
  end

  desc "remove_context DIRECTORY", "Remove a directory from Codebuddy's context"
  def remove_context(directory)
    @context_manager.remove_directory(directory)
    puts "#{directory} removed from context."
  end

  desc "ask QUERY", "Send a query to Codebuddy"
  def ask(query)
    response = @chat_gpt_assistant.send_request(query)
    puts "Response:\n#{response}"
  end

  private

  def save_config
    File.write(CONFIG_FILE, JSON.pretty_generate(@config))
  end

  def load_config
    if File.exist?(CONFIG_FILE)
      JSON.parse(File.read(CONFIG_FILE))
    else
      {}
    end
  end
end
