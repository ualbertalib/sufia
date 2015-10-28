require_relative 'abstract_migration_generator'

class Sufia::Models::InstallGenerator < Sufia::Models::AbstractMigrationGenerator
  source_root File.expand_path('../templates', __FILE__)
  argument :model_name, type: :string, default: "user"
  desc """
This generator makes the following changes to your application:
 1. Creates several database migrations if they do not exist in /db/migrate
 2. Adds user behavior to the user model
 3. Creates the sufia.rb configuration file
 4. Generates mailboxer
 5. Generates usage stats config
 6. Runs full-text generator
 7. Runs proxies generator
 8. Runs cached stats generator
 9. Runs ORCID field generator
10. Runs user stats generator
11. Runs citation config generator
12. Runs upload_to_collection config generator
13. Generates mini-magick config
       """
  def banner
    say_status("info", "GENERATING SUFIA MODELS", :blue)
  end

  # Setup the database migrations
  def copy_migrations
    [
      "acts_as_follower_migration.rb",
      "add_social_to_users.rb",
      "create_single_use_links.rb",
      "add_ldap_attrs_to_user.rb",
      "add_avatars_to_users.rb",
      "create_checksum_audit_logs.rb",
      "create_version_committers.rb",
      "add_groups_to_users.rb",
      "create_local_authorities.rb",
      "create_trophies.rb",
      'add_linkedin_to_users.rb',
      'create_tinymce_assets.rb',
      'create_content_blocks.rb',
      'create_featured_works.rb',
      'add_external_key_to_content_blocks.rb'
    ].each do |file|
      better_migration_template file
    end
  end

  # Add behaviors to the user model
  def inject_sufia_user_behavior
    file_path = "app/models/#{model_name.underscore}.rb"
    if File.exist?(file_path)
      inject_into_file file_path, after: /include Hydra\:\:User.*$/ do
        "# Connects this user object to Sufia behaviors. " +
          "\n include Sufia::User\n"
      end
    else
      puts "     \e[31mFailure\e[0m  Sufia requires a user object. This generators assumes that the model is defined in the file #{file_path}, which does not exist.  If you used a different name, please re-run the generator and provide that name as an argument. Such as \b  rails -g sufia client"
    end
  end

  def create_configuration_files
    append_file 'config/initializers/mime_types.rb',
                "\nMime::Type.register 'application/x-endnote-refer', :endnote", verbose: false
    copy_file 'config/sufia.rb', 'config/initializers/sufia.rb'
    copy_file 'config/redis.yml', 'config/redis.yml'
    copy_file 'config/resque-pool.yml', 'config/resque-pool.yml'
    copy_file 'config/redis_config.rb', 'config/initializers/redis_config.rb'
    copy_file 'config/resque_admin.rb', 'config/initializers/resque_admin.rb'
    copy_file 'config/resque_config.rb', 'config/initializers/resque_config.rb'
    copy_file 'config/resque.rake', 'lib/tasks/resque.rake'
  end

  def create_collection
    copy_file 'app/models/collection.rb', 'app/models/collection.rb'
  end

  def install_mailboxer
    generate "mailboxer:install"
  end

  def configure_usage_stats
    generate 'sufia:models:usagestats'
  end

  # Sets up full-text indexing (Solr config + jars)
  def full_text_indexing
    generate "sufia:models:fulltext"
  end

  # Sets up proxies and transfers
  def proxies
    generate "sufia:models:proxies"
  end

  # Sets up cached usage stats
  def cached_stats
    generate 'sufia:models:cached_stats'
  end

  # Adds orcid field to user model
  def orcid_field
    generate 'sufia:models:orcid_field'
  end

  # Adds user stats-related migration & methods
  def user_stats
    generate 'sufia:models:user_stats'
  end

  # Adds clamav initializtion
  def clamav
    generate 'sufia:models:clamav'
  end

  # Adds citations initialization
  def citation_config
    generate 'sufia:models:citation_config'
  end

  # Adds upload_to_collection initialization
  def upload_to_collection_config
    generate 'sufia:models:upload_to_collection_config'
  end

  # Add mini-magick configuration
  def minimagic_config
    generate 'sufia:models:minimagick_config'
  end
end
