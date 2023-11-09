class FileManager
  def initialize
    # Any initialization code needed
  end

  def create_file(file_path, content)
    File.open(file_path, 'w') { |file| file.write(content) }
    "File created: #{file_path}"
  rescue => e
    "Error creating file: #{e.message}"
  end

  def update_file(file_path, content)
    return "File does not exist: #{file_path}" unless File.exist?(file_path)

    File.open(file_path, 'w') { |file| file.write(content) }
    "File updated: #{file_path}"
  rescue => e
    "Error updating file: #{e.message}"
  end

  def delete_file(file_path)
    return "File does not exist: #{file_path}" unless File.exist?(file_path)

    File.delete(file_path)
    "File deleted: #{file_path}"
  rescue => e
    "Error deleting file: #{e.message}"
  end
end