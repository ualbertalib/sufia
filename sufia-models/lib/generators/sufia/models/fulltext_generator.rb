# -*- encoding : utf-8 -*-
require 'rails/generators'

class Sufia::Models::FulltextGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc """
This generator makes the following changes to your application:
 1. Copies solrconfig.xml into solr_conf/conf/
 2. Reconfigures jetty
       """

  def banner
    say_status("info", "GENERATING SUFIA FULL-TEXT", :blue)
  end

  # Copy Sufia's solrconfig into the dir from which the jetty:config task pulls
  # Sufia's solrconfig includes full-text extraction
  def copy_solr_config
    copy_file 'config/solrconfig.xml', 'solr_conf/conf/solrconfig.xml', force: true
  end

  # Copy config, schema, and jars into jetty dir if it exists
  def reconfigure_jetty
    rake "sufia:jetty:config" if File.directory?('jetty')
  end
end
