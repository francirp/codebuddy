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
    
    threads = config_manager.assistants.map do |assistant|
      thread_service = OpenAI::CreateThread.new
      thread_service.call
      role = assistant["role"]
      config_manager.threads["#{role}_thread_id"] = assistant["id"]
    end
        
    config_manager.save_config

    config_manager.context_manager = @context_manager
    config_manager.save_context
    
    puts "Codebuddy ready. Call `codebuddy ask -r [pm design dev]` to ask your AI Agents to do something."
  end

  desc "set_openai_key KEY", "Set your OpenAI API key"
  def set_openai_key(key)
    config_manager
    config_manager.openai_key = key
    config_manager.save_config
    puts "OpenAI API key updated."
  end

  # desc "create_assistant ROLE ID", "Create your OpenAI API key"
  # def create_assistant(role, id)
  #   config_manager
  #   config_manager.assistants[role] = id
  #   config_manager.save_config
  #   puts "Assistant added."
  # end  

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
  method_option :role, aliases: "-r", desc: "Specify the role (pm, designer, dev)", enum: ["pm", "designer", "dev"]
  def ask
    say "\e[1mAsk your AI buddy to do something or a question.\e[22m", :green
    print "> "
    query = $stdin.gets.strip
  
    role = options[:role] || "pm" # Retrieve the specified role
    say "AI role being used: #{role}" if role # Optionally, display the specified role
  
    ask_service = Ask.new(query, role) # Pass the role to your service
    ask_service.call
  
    ask_service.assistant_messages.each do |message|
      say message, :white
    end    
  end
  

  desc "prompt_from_file", "Build a prompt from a text file located at 'prompt.txt' and send it to Codebuddy"
  def prompt_from_file
    file_path = "prompt.txt"
    
    unless File.exist?(file_path)
      say "File not found: #{file_path}", :red
      return
    end
  
    file_contents = File.read(file_path).strip
    if file_contents.empty?
      say "File is empty.", :yellow
      return
    end
  
    # You can add any preprocessing to the file contents here if needed
  
    # Using the existing ask method infrastructure
    # Assuming Ask.new accepts the prompt and can handle it accordingly
    ask_service = Ask.new(file_contents)
    ask_service.call
  
    # Output the response from the GPT-4 service
    ask_service.assistant_messages.each do |message|
      say message, :white
    end
  end
  

  private

  def context_manager
    @context_manager ||= config_manager.context_manager
  end
end
