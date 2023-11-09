# frozen_string_literal: true

require_relative "codebuddy/version"
require_relative "./cli_interface"
require_relative "./command_executor"
require_relative "./chatgpt_assistant"
require_relative "./context_manager"
require_relative "./file_manager"

module Codebuddy
  class Error < StandardError; end
  # Your code goes here...
end