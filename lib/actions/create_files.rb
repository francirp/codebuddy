module Actions
  class CreateFiles < Action
    def call
      files = params["files"]
      files.each do |file|
        file_manager.create_file(file["file_path"], file["file_content"])
      end
      output = "success"
    end
  end
end
