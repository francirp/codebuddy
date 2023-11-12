require 'pathname'

class Ask
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def call
    puts prompt
    create_message
    create_run_and_poll    
  end

  def assistant_messages
    list_messages_service = OpenAI::ListMessages.new
    list_messages_service.call
    list_messages_service.recent_assistant_messages
  end  

  private

  def create_message
    message_service = OpenAI::CreateMessage.new(prompt)
    message_service.call
  end

  def create_run_and_poll
    run_service = OpenAI::CreateRun.new
    run_service.call

    finished = false
    while !finished
      sleep(2)
      retrieve_run_service = OpenAI::RetrieveRun.new(run_service.id)
      retrieve_run_service.call
      finished = retrieve_run_service.finished?
    end    
  end

  def prompt
    file_tree = build_directory_structure(context_manager.context_paths)
    %Q(
[User Message]
#{query}

[Code Repository File Structure]
#{file_tree}
    )
  end

  def context_manager
    ConfigManager.new.context_manager
  end

  def build_directory_structure(paths, prefix = '', result = '')
    paths.sort.each do |path|
      basename = File.basename(path)
  
      # Check if it's a directory
      if File.directory?(path)
        result += "#{prefix}#{basename}/\n"
        # Recursively list contents of the directory
        inner_paths = Dir.glob("#{path}/*")
        result = build_directory_structure(inner_paths, "#{prefix}  ", result)
      else
        result += "#{prefix}#{basename}\n"
      end
    end
    result
  end
end