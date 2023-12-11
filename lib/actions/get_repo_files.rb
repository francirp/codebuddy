module Actions
  class GetRepoFiles < Action
    def call
      files = params["file_paths"]
      puts "sending files: #{files}"
      output = files.map do |file|
        file_manager.get_file(file)
      end.join("\n\n")
  end
end
