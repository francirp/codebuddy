require 'thor'
require 'json'
require_relative 'context_manager'
require_relative 'chat_gpt_assistant'

class CLIInterface < Thor
  CONFIG_FILE = File.join(Dir.home, '.codebuddy_config.json')
  CONTEXT_FILE = File.join(Dir.home, '.codebuddy_context.json')

  def initialize(*args)
    super
    @config = load_config
    @chat_gpt_assistant = ChatGPTAssistant.new(api_key: @config['openai_key'])
  end

  desc "start", "Start a new Codebuddy session in the current directory"
  def start
    puts "Starting Codebuddy..."
    @context_manager = ContextManager.new
    save_context
    puts "Codebuddy ready."
  end

  desc "set_openai_key KEY", "Set your OpenAI API key"
  def set_openai_key(key)
    @config['openai_key'] = key
    save_config
    puts "OpenAI API key updated."
  end

  desc "add PATH", "Add a file or directory to Codebuddy's context by providing its path"
  def add(path)    
    result = context_manager.add_path(path)
    puts result
    save_context
  end

  desc "remove PATH", "Remove a file or directory from Codebuddy's context by providing its path"
  def remove(path)
    result = context_manager.remove_path(path)
    puts result
    save_context
  end

  desc "view", "View current paths in context and tokens"
  def view
    context_paths = context_manager.context_paths
    tokens = (context_manager.current_char_count / 4.0).round

    if context_paths.empty?
      puts "No context paths set."
    else
      puts "Estimated Total Tokens: #{tokens}"
      puts ""
      puts "Current context paths:\n"
      context_paths.each { |path| puts "  \u2022 #{path}" }
    end
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

  def context_manager
    @context_manager ||= load_context
  end

  def save_context
    File.write(CONTEXT_FILE, JSON.pretty_generate(@context_manager.to_h))
  end

  def load_context
    if File.exist?(CONTEXT_FILE)
      ContextManager.from_h(JSON.parse(File.read(CONTEXT_FILE)))
    else
      ContextManager.new
    end
  end  
end
