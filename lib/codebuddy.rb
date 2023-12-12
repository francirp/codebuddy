# frozen_string_literal: true
require "pry"
require "httparty"
require_relative "codebuddy/version"
require_relative "./command_executor"
require_relative "./generate_tree"
require_relative "./context_manager"
require_relative "./file_manager"
require_relative "./config_manager"
require_relative "./ask"
require_relative "./apply_diff"
require_relative "./cli_interface"

Dir.glob(File.join(File.dirname(__FILE__), 'open_ai', '*.rb')).each do |file|
  require_relative file
end

Dir.glob(File.join(File.dirname(__FILE__), 'actions', '*.rb')).each do |file|
  require_relative file
end


module Codebuddy
  class Error < StandardError; end
  # Your code goes here...
end
