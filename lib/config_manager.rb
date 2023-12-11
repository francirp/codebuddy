class ConfigManager
  CONFIG_FILE = File.join(Dir.home, '.codebuddy_config.json')
  CONTEXT_FILE = File.join(Dir.home, '.codebuddy_context.json')

  attr_accessor :openai_key, :threads, :assistants, :context_manager

  def initialize
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
      design_assistant_id: design_assistant_id,
      dev_assistant_id: dev_assistant_id,
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
      { 'role' => 'pm', 'id' => 'asst_BlL1TdPlf44EVcf1ZbWuzzB4'},
      { 'role' => 'design', 'id' => 'asst_YEiAj7SWMRws3X4s19VXU4If'},
      { 'role' => 'dev', 'id' => 'asst_U1V5mpmhHpmuvEQYU5ZudKJ2'},
    ]
  end
end