class ApplyDiff
  attr_reader :file_path, :diffs

  def initialize(file_path, diffs)
    @file_path = file_path
    @diffs = diffs
  end

  def call
    file_lines = File.readlines(file_path)

    # Sort diffs by line number in descending order
    diffs.sort_by! { |diff| diff["line_number"] }.reverse!
    diffs.each do |diff|
      line_number = diff["line_number"] - 1  # Array index starts at 0
      
      case diff["action"]
      when "replace"
        # Replace the line at the specified line number
        file_lines[line_number] = diff["line"] + "\n"
      when "add"
        # Insert a new line
        file_lines.insert(line_number, diff["line"] + "\n")
      when "remove"
        # Delete the line at the specified line number
        file_lines.delete_at(line_number)
      end
    end

    File.open(file_path, "w") do |file|
      file_lines.each { |line| file.puts line }
    end
  end
end
