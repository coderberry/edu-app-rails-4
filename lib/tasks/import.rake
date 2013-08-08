namespace :import do

  task :organizations => :environment do
    json = JSON.parse(File.read("#{Rails.root}/data/dump.json"))
  end

end