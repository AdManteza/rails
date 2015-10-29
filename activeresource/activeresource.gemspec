require File.expand_path('../../railslts-version/lib/railslts-version', __FILE__)

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'activeresource'
  s.version     = RailsLts::VERSION::STRING
  s.summary     = 'REST modeling framework (part of Rails).'
  s.description = 'REST on Rails. Wrap your RESTful web app with Ruby classes and work with them like Active Record models.'

  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'David Heinemeier Hansson'
  s.email             = 'david@loudthinking.com'
  s.homepage          = 'http://www.rubyonrails.org'
  s.rubyforge_project = 'activeresource'

  s.files        = Dir['CHANGELOG', 'LICENSE', 'README.rdoc', 'examples/**/*', 'lib/**/*']
  s.require_path = 'lib'

  s.extra_rdoc_files = %w( README.rdoc )
  s.rdoc_options.concat ['--main',  'README.rdoc']

  s.add_dependency('activesupport', "= #{RailsLts::VERSION::STRING}")
  s.add_dependency('activemodel',   "= #{RailsLts::VERSION::STRING}")
end
