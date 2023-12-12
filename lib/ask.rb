require 'pathname'

class Ask
  attr_reader :query, :role, :thread_id, :assistant_id

  def initialize(query, role)
    @query = query
    @role = role

    @thread_id = config_manager.threads["#{role}_thread_id"]
    assistant = config_manager.assistants.detect {|a| a["role"] == role }
    raise "The #{role} assistant was not found. Please create the assistant first." unless assistant
    @assistant_id = assistant["id"]
  end

  def call
    puts prompt
    create_message
    create_run_and_poll    
  end

  def assistant_messages
    list_messages_service = OpenAI::ListMessages.new(thread_id)
    list_messages_service.call
    list_messages_service.recent_assistant_messages
  end  

  private

  def create_message
    message_service = OpenAI::CreateMessage.new(prompt, thread_id)
    message_service.call
  end

  def create_run_and_poll
    run_service = OpenAI::CreateRun.new(thread_id, assistant_id)
    run_service.call

    finished = false
    while !finished
      sleep(2)
      retrieve_run_service = OpenAI::RetrieveRun.new(run_service.id, thread_id)
      retrieve_run_service.call
      finished = retrieve_run_service.finished?
    end    
  end

  def prompt
    absolute_paths = context_manager.context_paths.map { |path| File.expand_path(path) }
    tree_generator = GenerateTree.new(absolute_paths)
    file_tree = tree_generator.call

    %Q(
[User Message]
#{query}

#{file_tree.empty? ? "" : "[Content & Code Repository Structure]"}
Note: The codebuddy-workspace directory contains product & design resources from the LaunchPad Lab team that you can fetch to understand the product & design plan.

#{file_tree}
    )
  end

  def config_manager
    @config_manager ||= ConfigManager.new
  end

  def context_manager
    @context_manager ||= config_manager.context_manager
  end

  def generate_tree_structure(paths)
    cwd = Dir.pwd
  
    # Convert absolute paths to relative paths
    relative_paths = paths.map { |path| Pathname.new(path).relative_path_from(Pathname.new(cwd)).to_s }
  
    # Build and return the tree structure
    build_tree(relative_paths)
  end
  
  def build_tree(paths)
    tree = {}
    
    paths.each do |path|
      current_level = tree
  
      path.split('/').each do |part|
        current_level[part] ||= {}
        current_level = current_level[part]
      end
    end
  
    format_tree(tree)
  end
  
  def format_tree(node, prefix = "")
    node.map do |key, children|
      if children.empty?
        "#{prefix}#{key}"
      else
        "#{prefix}#{key}/\n" + format_tree(children, "#{prefix}  ")
      end
    end.join("\n")
  end

  # def product_content
  #   files = Dir.glob(File.join('./codebuddy-workspace', 'content', '**/*')).select do |file|
  #     File.file?(file)
  #   end

  #   files.map do |file_path|
  #     file_lines = File.readlines(file_path)
  #     lines_string = file_lines.map.with_index {|line, i| "#{i + 1}. #{line}"}.join
  #     "#{file_path}:\n```\n#{lines_string}\n```\n\n"
  # end

  # def handle_directory(directory_path)
  #   allowed_files = get_allowed_files(directory_path)
    
  #   result = allowed_files.map do |file|
  #     handle_file(file)
  #   end.join("\n\n")
  # end

  # def handle_file(file_path)

  # end  
end