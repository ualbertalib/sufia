source 'https://rubygems.org'

# Please see sufia.gemspec for dependency information.
gemspec

# Required for doing pagination inside an engine. See https://github.com/amatsuda/kaminari/pull/322
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'
gem 'sufia-models', path: './sufia-models'
gem 'sass', '~> 3.2.15'
gem 'sprockets', '~> 2.11.0'
gem 'active-fedora', github: 'projecthydra/active_fedora', branch: 'fedora-4'
gem 'hydra-head', github: 'psu-stewardship/hydra-head', branch: 'fedora-4'
gem 'hydra-collections', github: 'projecthydra/hydra-collections', branch: 'fedora-4'

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'launchy' unless ENV['TRAVIS']
  gem 'byebug' unless ENV['TRAVIS']
  gem 'capybara'
  gem "jettywrapper"
  gem "factory_girl_rails"
  gem "devise"
  gem 'jquery-rails'
  gem 'turbolinks'
  gem "bootstrap-sass"
  gem "simplecov", :require => false
end # (leave this comment here to catch a stray line inserted by blacklight!)
