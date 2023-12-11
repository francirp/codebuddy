module Actions
  class DeleteRepoFiles < Action
    def call
      files = params["file_paths"]
      files.each do |file|
        file_manager.delete_file(file)
      end
      output = "success"
    end
  end
end
