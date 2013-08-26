namespace :import do
  # Wipeout tables and import from JSON dump (CAREFUL!)
  task :all => :environment do
    Importer.new.run
  end
end