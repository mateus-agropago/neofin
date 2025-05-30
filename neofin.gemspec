# frozen_string_literal: true

# Require the version file to access the Neofin::VERSION constant.
require_relative "lib/neofin/version"

# Gem::Specification holds all the metadata for your gem.
Gem::Specification.new do |spec|
  # The name of the gem. This is how users will install it (gem install neofin).
  spec.name = "neofin"
  # The current version of the gem, loaded from lib/neofin/version.rb.
  spec.version = Neofin::VERSION
  # The author(s) of the gem.
  spec.authors = ["Pedro de Castro e Silva"]
  # Contact email address(es) for the author(s).
  spec.email = ["pedrocastros027@gmail.com"]

  # A short summary of the gem's purpose. Displayed in `gem list`.
  spec.summary = "A non official Ruby client for the Neofin Payments API."
  # A more detailed description of the gem.
  spec.description = "Provides a non official Ruby interface for interacting with the Neofin Payments API (v2023-12),
  allowing creation, retrieval, update, and cancellation of invoices and customer management."

  # The URL for the gem's homepage (usually the GitHub repository).
  spec.homepage = "https://github.com/PedroCastr0/neofin"
  # The license under which the gem is distributed (e.g., "MIT"). Make sure a LICENSE file exists.
  spec.license = "MIT"
  # The minimum version of Ruby required to use this gem.
  spec.required_ruby_version = ">= 3.1.0"

  # Link to the gem's homepage.
  spec.metadata["homepage_uri"] = spec.homepage
  # Link to the source code repository.
  spec.metadata["source_code_uri"] = spec.homepage
  # Link to the changelog file (good practice). Assumes CHANGELOG.md exists.
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || # Exclude the gemspec file itself
        # Exclude common directories/files not needed in the packaged gem
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  # Specifies the directory where executables (scripts) reside.
  spec.bindir = "exe"
  # Lists the actual executable files, derived from `spec.files`.
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  # Specifies the directory containing the library code (relative to the gem's root).
  # When someone requires your gem, Ruby looks in these paths.
  spec.require_paths = ["lib"]

  # List gems needed for DEVELOPMENT and TESTING, but not required by users of your gem.
  # Common examples include testing frameworks, linters, and build tools.
  spec.add_development_dependency "bundler", ">= 2.6.7" # Bundler itself
  spec.add_development_dependency "rake", "~> 13.0"     # Task runner
  # Add your testing framework (e.g., RSpec or Minitest)
  # spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "minitest", "~> 5.16"
  # Add linters/formatters if you use them
  spec.add_development_dependency "rubocop", "~> 1.21"
  # Add any other development tools
  spec.add_development_dependency "webmock", "~> 3.25.1" # For debugging

  # For more information and examples about making a new gem, check out the Bundler guide:
  # https://bundler.io/guides/creating_gem.html
end
