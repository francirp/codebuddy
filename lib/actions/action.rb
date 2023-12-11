module Actions
  class Action
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def run
      begin
        call
      rescue => e
        e.message
      end     
    end

    def file_manager
      @file_manager ||= FileManager.new
    end    
  end
end