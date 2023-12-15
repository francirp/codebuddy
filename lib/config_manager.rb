class ConfigManager
  CODEBUDDY_DIRECTORY = 'codebuddy-workspace'
  CONFIG_DIRECTORY = "#{CODEBUDDY_DIRECTORY}/config"
  CONFIG_FILE = File.join(CONFIG_DIRECTORY, '.codebuddy_config.json')
  CONTEXT_FILE = File.join(CONFIG_DIRECTORY, '.codebuddy_context.json')
  CONTENT_DIRECTORY = "#{CODEBUDDY_DIRECTORY}/content"
  TODOS_DIRECTORY = "#{CODEBUDDY_DIRECTORY}/todos"
  PROMPT_FILE_PATH = "#{CODEBUDDY_DIRECTORY}/prompt.md"

  attr_accessor :openai_key, :threads, :assistants, :context_manager

  def initialize
    update_gitignore
    make_directories    
    config = load_config
    @openai_key = config["openai_key"]
    @threads = config["threads"] || {}
    @assistants = config["assistants"] || create_default_assistants
    @context_manager = load_context
  end

  def save_config        
    hash = {
      openai_key: openai_key,
      threads: threads,
      assistants: assistants,
    }
    File.write(CONFIG_FILE, JSON.pretty_generate(hash))
  end

  def load_config
    if File.exist?(CONFIG_FILE)
      JSON.parse(File.read(CONFIG_FILE))
    else
      {}
    end
  end

  def save_context
    File.write(CONTEXT_FILE, JSON.pretty_generate(context_manager.to_h))
  end

  def load_context
    if File.exist?(CONTEXT_FILE)
      ContextManager.from_h(JSON.parse(File.read(CONTEXT_FILE)))
    else
      ContextManager.new
    end
  end

  private

  def create_default_assistants
    @assistants = [
      { 'role' => 'cp', 'id' => 'asst_aNABKJEPVDVFYEH4jYHJzie8'},
      { 'role' => 'pm', 'id' => 'asst_BlL1TdPlf44EVcf1ZbWuzzB4'},
      { 'role' => 'designer', 'id' => 'asst_YEiAj7SWMRws3X4s19VXU4If'},
      { 'role' => 'dev', 'id' => 'asst_U1V5mpmhHpmuvEQYU5ZudKJ2'},
    ]
  end

  def update_gitignore
    gitignore_path = './.gitignore'
    codebuddy_ignore_entry = CONFIG_DIRECTORY

    if File.exist?(gitignore_path)
      gitignore_contents = File.read(gitignore_path)

      # Check if the ignore entry already exists
      unless gitignore_contents.include?(codebuddy_ignore_entry)
        # Append the entry to the .gitignore file
        File.open(gitignore_path, 'a') do |file|
          file.puts "\n#{codebuddy_ignore_entry}"
        end
      end
    else
      # Create a new .gitignore file with the ignore entry
      File.write(gitignore_path, codebuddy_ignore_entry)
    end
  end
  
  def make_directories
    FileUtils.mkdir_p(CONFIG_DIRECTORY) unless Dir.exist?(CONFIG_DIRECTORY)
    FileUtils.mkdir_p(CONTENT_DIRECTORY) unless Dir.exist?(CONTENT_DIRECTORY)
    FileUtils.mkdir_p(TODOS_DIRECTORY) unless Dir.exist?(TODOS_DIRECTORY)
    File.write(PROMPT_FILE_PATH, "") unless File.exist?(PROMPT_FILE_PATH)
  end
end