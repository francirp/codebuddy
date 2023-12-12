module Actions
  class ReplaceRepoFiles < Action
    def call
      files = params["files"]
      files.each do |file|
        file_manager.replace_file(file["file_path"], file["file_content"])
      end
      output = "success"
    end
  end
end
