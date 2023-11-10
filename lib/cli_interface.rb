require 'thor'
  # color options for Thor:
    # :on_blue, :bold, :black, :red, :yellow, :blue, :magenta, :cyan, :white, 
    # :on_black, :on_red, :on_green, :on_yellow, :on_magenta, :on_cyan, :on_white
require 'json'

class CLIInterface < Thor
  attr_reader :config_manager

  def initialize(*args)
    super
    @config_manager = ConfigManager.new
  end

  desc "start", "Start a new Codebuddy session in the current directory"
  def start
    puts "Starting Codebuddy..."
    @context_manager = ContextManager.new
    
    thread_service = OpenAI::CreateThread.new
    thread_service.call
    config_manager.thread_id = thread_service.id
    config_manager.save_config
    
    config_manager.context_manager = @context_manager
    config_manager.save_context
    
    puts "Codebuddy ready. Call `codebuddy ask` to ask your AI Agent to do something."
  end

  desc "set_openai_key KEY", "Set your OpenAI API key"
  def set_openai_key(key)
    config_manager
    config_manager.openai_key = key
    config_manager.save_config
    puts "OpenAI API key updated."
  end

  desc "add PATH", "Add a file or directory to Codebuddy's context by providing its path"
  def add(path)    
    result = context_manager.add_path(path)
    puts result
    config_manager.save_context
  end

  desc "remove PATH", "Remove a file or directory from Codebuddy's context by providing its path"
  def remove(path)
    result = context_manager.remove_path(path)
    puts result
    config_manager.save_context
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

  desc "ask", "Send a query to Codebuddy"
  def ask
    say "\e[1mAsk your AI buddy to do something or a question.\e[22m", :green
    print "  > "
    query = $stdin.gets.strip

    ask_service = Ask.new(query)
    ask_service.call
    
    ask_service.assistant_messages.each do |message|
      say "\e[1m#{message}\e[22m", :green
    end
  end

  private

  def context_manager
    @context_manager ||= config_manager.context_manager
  end
end
