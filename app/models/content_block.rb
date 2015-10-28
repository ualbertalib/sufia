class ContentBlock < ActiveRecord::Base
  MARKETING  = 'marketing_text'
  RESEARCHER = 'featured_researcher'
  ANNOUNCEMENT = 'announcement_text'

  def self.recent_researchers
    where(name: RESEARCHER).order('created_at DESC')
  end

  def self.featured_researcher
    recent_researchers.first
  end

  def self.external_keys
    { RESEARCHER => 'User' }
  end

  def external_key_name
    self.class.external_keys.fetch(name) { 'External Key' }
  end
end
