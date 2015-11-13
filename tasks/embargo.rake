namespace :sufia do
  desc "Remove lapsed embargoes"
  task :remove_lapsed_embargoes => :environment do |t|
    items = Hydra::EmbargoService.assets_with_expired_embargoes
    items.each do |item|
      item.embargo_visibility!
      item.embargo.save!
      item.save!
    end   
  end
end
