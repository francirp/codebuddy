class ConfigManager
  CONFIG_FILE = File.join(Dir.home, '.codebuddy_config.json')
  CONTEXT_FILE = File.join(Dir.home, '.codebuddy_context.json')

  attr_accessor :openai_key, :thread_id, :context_manager

  def initialize
    config = load_config
    @openai_key = config["openai_key"]
    @thread_id = config["thread_id"]
    @context_manager = load_context
  end

  def save_config
    hash = {
      openai_key: openai_key,
      thread_id: thread_id,
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
end