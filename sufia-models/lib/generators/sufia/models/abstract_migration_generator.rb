# -*- encoding : utf-8 -*-
require 'rails/generators'
require 'rails/generators/migration'

class Sufia::Models::AbstractMigrationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  # Implement the required interface for Rails::Generators::Migration.
  # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
  def self.next_migration_number(path)
    if @prev_migration_nr
      @prev_migration_nr += 1
    else
      last_migration = Dir[File.join(path, '*.rb')].sort.last
      if last_migration
        @prev_migration_nr = last_migration.sub(File.join(path, '/'), '').to_i + 1
      else
        @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
      end
    end
    @prev_migration_nr.to_s
  end

  protected

    def better_migration_template(file)
      migration_template "migrations/#{file}", "db/migrate/#{file}"
    rescue Rails::Generators::Error => e
      say_status("error", e.message, :red)
    end
end
