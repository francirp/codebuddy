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
    absolute_paths = context_manager.context_paths.map { |path| File.expand_path(path) }
    tree_generator = GenerateTree.new(absolute_paths)
    file_tree = tree_generator.call

    %Q(
[User Message]
#{query}

#{file_tree.empty? ? "" : "[Code Repository File Structure]"}
#{file_tree}
    )
  end

  def context_manager
    ConfigManager.new.context_manager
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
end