class Ask
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def call
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
    %Q(
      [User Message]
      #{query}

      [Code Repository]
      #{context_manager.current_context}
    )
  end

  def context_manager
    ConfigManager.new.context_manager
  end
end