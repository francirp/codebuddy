class ContextManager
  MAX_TOKEN_LIMIT = 100_000
  AVG_CHARS_PER_TOKEN = 4
  MAX_CHAR_LIMIT = MAX_TOKEN_LIMIT * AVG_CHARS_PER_TOKEN
  ALLOWED_EXTENSIONS = ['.rb', '.txt', '.css', '.html', '.erb', '.js', '.jsx', 'Gemfile']

  attr_reader :context_paths, :current_char_count

  def initialize
    @context_paths = []
    @current_char_count = 0
  end

  def add_path(path)
    path = resolve_full_path(path)
    return "Path #{path} already in context." if @context_paths.include?(path)
    return "Path does not exist." unless File.exist?(path)
    return "Adding #{path} exceeds the maximum token limit." if exceeds_token_limit?(path)    

    if File.file?(path)
      allowed_file_type?(path) ? add_path_to_context(path) : unsupported_file_type_message(path)
    elsif File.directory?(path)
      add_directory_to_context(path)
    end
  end

  def remove_path(path)
    path = resolve_full_path(path)
    return "Path not found in context." unless @context_paths.delete(path)

    @current_char_count -= calculate_char_count(path)
    @current_char_count = 0 if @context_paths.empty?
    "Path #{path} removed from context."
  end

  def current_context
    @context_paths.map do |path|
      if File.directory?(path)
        handle_directory(path)
      elsif File.file?(path)
        handle_file(path)
      end
    end.compact.join("\n\n")
  end

  def to_h
    {
      'context_paths' => @context_paths,
      'current_char_count' => @current_char_count
      # Include other relevant attributes here
    }
  end

  def self.from_h(hash)
    new_context_manager = new
    new_context_manager.instance_variable_set(:@context_paths, hash['context_paths'])
    new_context_manager.instance_variable_set(:@current_char_count, hash['current_char_count'])
    # Set other attributes from the hash as needed
    new_context_manager
  end
  
  private

  def resolve_full_path(path)
    normalized_path = path.chomp('/') # Remove trailing slash
    return normalized_path if path_absolute?(normalized_path)

    File.join(Dir.pwd, normalized_path)
  end

  def path_absolute?(path)
    Pathname.new(path).absolute?
  end

  def exceeds_token_limit?(path)
    new_char_count = @current_char_count + calculate_char_count(path)
    new_char_count > MAX_CHAR_LIMIT
  end

  def calculate_char_count(path)
    if File.directory?(path)
      allowed_files = get_allowed_files(path)
      allowed_files.sum { |file| File.read(file).length }
    elsif File.file?(path)
      File.read(path).length
    else
      0
    end
  end

  def allowed_file_type?(path)
    ALLOWED_EXTENSIONS.include?(File.extname(path))
  end

  def add_path_to_context(path)   
    @context_paths << path
    @current_char_count += calculate_char_count(path)
    "Path #{path} added to context."
  end

  def unsupported_file_type_message(path)
    "Unsupported file type for #{path}. Supported types are: #{ALLOWED_EXTENSIONS.join(', ')}"
  end

  def add_directory_to_context(path)
    unsupported_files = Dir.glob(File.join(path, '**/*')).reject do |file|
      File.directory?(file) || allowed_file_type?(file)
    end
        
    directory_contains_unsupported_files_error(unsupported_files) if unsupported_files.any?
    add_path_to_context(path)
  end

  def directory_contains_unsupported_files_error(unsupported_files)
    warning_message = "\e[33mWarning: The following files have unsupported types and will not be included: "
    warning_message += unsupported_files.join(', ')
    warning_message += "\nSupported types are: #{ALLOWED_EXTENSIONS.join(', ')}\e[0m"
    puts warning_message
  end

  def get_allowed_files(directory_path)
    Dir.glob(File.join(directory_path, '**/*')).select do |file|
      File.file?(file) && ALLOWED_EXTENSIONS.include?(File.extname(file))
    end
  end

  def handle_directory(directory_path)
    allowed_files = get_allowed_files(directory_path)
    
    result = allowed_files.map do |file|
      handle_file(file)
    end.join("\n\n")
  end

  def handle_file(file_path)
    file_lines = File.readlines(file_path)
    lines_string = file_lines.map.with_index {|line, i| "#{i + 1}. #{line}"}.join
    "#{file_path}:\n```\n#{lines_string}\n```\n\n"
  end
end
