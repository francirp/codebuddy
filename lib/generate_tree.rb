require 'pathname'

class GenerateTree
  def initialize(paths)
    @base_paths = paths
  end

  def call
    expanded_paths = expand_paths(@base_paths)
    generate_tree_structure(expanded_paths)
  end

  private

  def expand_paths(paths)
    expanded = []

    paths.each do |path|
      if File.directory?(path)
        Dir.glob("#{path}/**/*").each do |sub_path|
          expanded << sub_path
        end
      else
        expanded << path
      end
    end

    expanded
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
      parts = path.split('/')

      parts.each_with_index do |part, index|
        if index == parts.size - 1
          current_level[part] = nil
        else
          current_level[part] ||= {}
          current_level = current_level[part]
        end
      end
    end

    format_tree(tree)
  end

  def format_tree(node, prefix = "")
    node.map do |key, children|
      if children.nil?
        "#{prefix}#{key}" # File
      else
        "#{prefix}#{key}/\n" + format_tree(children, "#{prefix}  ")
      end
    end.join("\n")
  end
end
