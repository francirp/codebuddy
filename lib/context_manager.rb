class ContextManager
  MAX_TOKEN_LIMIT = 100_000
  AVG_CHARS_PER_TOKEN = 4
  MAX_CHAR_LIMIT = MAX_TOKEN_LIMIT * AVG_CHARS_PER_TOKEN
  ALLOWED_EXTENSIONS = ['.rb', '.txt', '.css', '.html', '.erb', '.js', '.jsx']

  def initialize
    @context_paths = []
    @current_char_count = 0
  end

  def add_path(path)
    if exceeds_token_limit?(path)
      raise "Adding #{path} exceeds the maximum token limit."
    end

    return "Path does not exist." unless File.exist?(path)

    if File.file?(path)
      allowed_file_type?(path) ? add_file_to_context(path) : unsupported_file_message(path)
    elsif File.directory?(path)
      add_directory_to_context(path)
    end
  end

  def remove_path(path)
    if @context_paths.delete(path)
      @current_char_count -= calculate_char_count(path)
      "Path #{path} removed from context."
    else
      "Path not found in context."
    end
  end

  def current_context
    @context_paths.map do |path|
      if File.directory?(path)
        handle_directory(path)
      elsif File.file?(path)
        "#{path}:\n#{File.read(path)}"
      end
    end.compact.join("\n\n")
  end

  private

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

  def add_file_to_context(path)
    @context_paths << path
    @current_char_count += calculate_char_count(path)
    "Path #{path} added to context."
  end

  def unsupported_file_message(path)
    "\e[31mUnsupported file type for #{path}. Supported types are: #{ALLOWED_EXTENSIONS.join(', ')}\e[0m"
  end

  def add_directory_to_context(path)
    unsupported_files = Dir.glob(File.join(path, '**/*')).reject do |file|
      File.directory?(file) || allowed_file_type?(file)
    end

    if unsupported_files.any?
      warning_message = "\e[33mWarning: The following files have unsupported types and will not be included: "
      warning_message += unsupported_files.join(', ')
      warning_message += "\nSupported types are: #{ALLOWED_EXTENSIONS.join(', ')}\e[0m"
      puts warning_message
    end

    handle_directory(path)
  end

  def get_allowed_files(directory_path)
    Dir.glob(File.join(directory_path, '**/*')).select do |file|
      File.file?(file) && ALLOWED_EXTENSIONS.include?(File.extname(file))
    end
  end

  def handle_directory(directory_path)
    allowed_files = get_allowed_files(directory_path)
    
    allowed_files.map do |file|
      "#{file}:\n#{File.read(file)}"
    end.join("\n\n")
  end
end
