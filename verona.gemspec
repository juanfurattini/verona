# frozen_string_literal: true

# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'verona/version'

Gem::Specification.new do |spec|
  spec.name = 'verona'
  spec.version = Verona::VERSION
  spec.authors = ['Juan Furattini']
  spec.email = 'juan.furattini@gmail.com'
  spec.platform = Gem::Platform::RUBY

  spec.summary = 'Google PlayStore In-App Purchase Receipt Verification'
  spec.description = 'Ruby Gem for In-App Purchase Receipt Verification'
  spec.homepage = 'https://www.linkedin.com/in/furattinijuan/'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against ' \
  #     'public gem pushes.'
  # end

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'json'
  spec.add_dependency 'retriable', '~> 3.1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rubocop'
end
