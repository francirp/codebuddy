module Actions
  class UpdateRepoFiles < Action
    def call
      files = params["files"]
      files.each do |file|
        diffs = file["diffs"]
        file_manager.update_file(file["file_path"], diffs)
      end
      output = "success"
    end
  end
end
