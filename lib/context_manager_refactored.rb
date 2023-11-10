require 'pathname'

class PathResolver
  def initialize(base_directory)
    @base_directory = base_directory
  end

  def resolve_full_path(path)
    normalized_path = path.chomp('/')
    return normalized_path if path_absolute?(normalized_path)

    File.join(@base_directory, normalized_path)
  end

  def path_absolute?(path)
    Pathname.new(path).absolute?
  end
end

class CharCounter
  def initialize
    @current_char_count = 0
  end

  attr_reader :current_char_count

  def calculate_char_count(path, allowed_extensions)
    if File.directory?(path)
      allowed_files = get_allowed_files(path, allowed_extensions)
      allowed_files.sum { |file| File.read(file).length }
    elsif File.file?(path)
      File.read(path).length
    else
      0
    end
  end

  def get_allowed_files(directory_path, allowed_extensions)
    Dir.glob(File.join(directory_path, '**/*')).select do |file|
      File.file?(file) && allowed_extensions.include?(File.extname(file))
    end
  end

  def update_char_count(additional_chars)
    @current_char_count += additional_chars
  end

  def reset_char_count
    @current_char_count = 0
  end
end

class FileTypeValidator
  attr_reader :allowed_extensions

  def initialize(allowed_extensions)
    @allowed_extensions = allowed_extensions
  end

  def allowed_file_type?(path)
    allowed_extensions.include?(File.extname(path))
  end

  def unsupported_file_types(directory_path)
    Dir.glob(File.join(directory_path, '**/*')).reject do |file|
      File.directory?(file) || allowed_file_type?(file)
    end
  end
end

class ContextStorage
  MAX_TOKEN_LIMIT = 100_000
  AVG_CHARS_PER_TOKEN = 4
  MAX_CHAR_LIMIT = MAX_TOKEN_LIMIT * AVG_CHARS_PER_TOKEN

  def initialize
    @context_paths = []
  end

  attr_reader :context_paths

  def add_path_to_context(path, char_count)
    return "Adding #{path} exceeds the maximum token limit." if char_count > MAX_CHAR_LIMIT
    @context_paths << path
    "Path #{path} added to context."
  end

  def remove_path_from_context(path, char_count)
    @context_paths.delete(path)
    char_count
  end
end

class ContextSerializer
  def to_h(context_storage, char_counter)
    {
      'context_paths' => context_storage.context_paths,
      'current_char_count' => char_counter.current_char_count
    }
  end

  def self.from_h(hash, context_storage, char_counter)
    context_storage.instance_variable_set(:@context_paths, hash['context_paths'])
    char_counter.instance_variable_set(:@current_char_count, hash['current_char_count'])
    [context_storage, char_counter]
  end
end

class ContextRenderer
  def intialize
  end

  def render(context_paths)
    context_paths.map do |path|
      if File.directory?(path)
        handle_directory(path)
      elsif File.file?(path)
        "#{path}:
#{File.read(path)}"
      end
    end.compact.join("\n\n")
  end

  def handle_directory(directory_path)
    allowed_files = get_allowed_files(directory_path)
    
    allowed_files.map do |file|
      "#{file}:
#{File.read(file)}"
    end.join("\n\n")
  end
end

class ContextManagerRefactored
  ALLOWED_EXTENSIONS = ['.rb', '.txt', '.css', '.html', '.erb', '.js', '.jsx']

  def initialize
    @base_directory = Dir.pwd
    @path_resolver = PathResolver.new(@base_directory)
    @char_counter = CharCounter.new
    @file_type_validator = FileTypeValidator.new(ALLOWED_EXTENSIONS)
    @context_storage = ContextStorage.new
    @context_renderer = ContextRenderer.new
    @context_serializer = ContextSerializer.new
  end

  def add_path(path)
    path = @path_resolver.resolve_full_path(path)
    return "Path #{path} already in context." if @context_storage.context_paths.include?(path)
    return "Path does not exist." unless File.exist?(path)

    char_count = @char_counter.calculate_char_count(path, ALLOWED_EXTENSIONS)
    return "Adding #{path} exceeds the maximum token limit." if char_count > ContextStorage::MAX_CHAR_LIMIT

    if @file_type_validator.allowed_file_type?(path)
      add_message = @context_storage.add_path_to_context(path, char_count)
      @char_counter.update_char_count(char_count)
      add_message
    else
      unsupported_files = @file_type_validator.unsupported_file_types(path)
      if unsupported_files.any?
        directory_contains_unsupported_files_error(unsupported_files)
      else
        "Unsupported file type for #{path}. Supported types are: #{ALLOWED_EXTENSIONS.join(', ')}"
      end
    end
  end

  def remove_path(path)
    path = @path_resolver.resolve_full_path(path)
    return "Path not found in context." unless @context_storage.context_paths.include?(path)

    char_count = @char_counter.current_char_count
    updated_char_count = @context_storage.remove_path_from_context(path, char_count)
    @char_counter.update_char_count(-updated_char_count)
    @char_counter.reset_char_count if @context_storage.context_paths.empty?
    "Path #{path} removed from context."
  end

  def current_context
    @context_renderer.render(@context_storage.context_paths)
  end

  def to_h
    @context_serializer.to_h(@context_storage, @char_counter)
  end

  def self.from_h(hash)
    new_context_manager = new
    @context_storage, @char_counter = ContextSerializer.from_h(hash, @context_storage, @char_counter)
    new_context_manager
  end

  private

  def directory_contains_unsupported_files_error(unsupported_files)
    warning_message = "\e[33mWarning: The following files have unsupported types and will not be included: "
    warning_message += unsupported_files.join(', ')
    warning_message += "\nSupported types are: " + ALLOWED_EXTENSIONS.join(', ') + "\e[0m"
    puts warning_message
  end
end
