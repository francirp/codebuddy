class FileManager
  def initialize
    # Any initialization code needed
  end

  def create_file(file_path, content)
    puts "creating file #{file_path}"
    File.open(file_path, 'w') { |file| file.write(content) }
    puts "File created: #{file_path}"
  end

  def update_file(file_path, diffs)
    puts "starting diff service"
    apply_diff_service = ApplyDiff.new(file_path, diffs)
    apply_diff_service.call
    puts "File changed: #{file_path}"
  end  

  def replace_file(file_path, content)
    puts "replacing file #{file_path}"
    return "File does not exist: #{file_path}" unless File.exist?(file_path)

    File.open(file_path, 'w') { |file| file.write(content) }
    puts "File updated: #{file_path}"
  end

  def delete_file(file_path)
    puts "deleting file #{file_path}"
    return "File does not exist: #{file_path}" unless File.exist?(file_path)

    File.delete(file_path)
    puts "File deleted: #{file_path}"
  end
end
