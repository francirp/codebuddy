# frozen_string_literal: true

require_relative "lib/codebuddy/version"

Gem::Specification.new do |spec|
  spec.name = "codebuddy"
  spec.version = Codebuddy::VERSION
  spec.authors = ["Ryan Francis"]
  spec.email = ["ryan.p.francis@gmail.com"]

  spec.summary = "CLI for GPT to make repo-wide changes such as new features or bug fixes"
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/francirp/codebuddy"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/francirp/codebuddy"
  spec.metadata["changelog_uri"] = "https://github.com/francirp/codebuddy/changelog"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "bin"
  # spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.executables = ['codebuddy']
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "thor"
  spec.add_dependency "httparty"
  spec.add_dependency "pry"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
