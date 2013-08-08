namespace :db do
  namespace :migrate do
    desc "Migrate the database for development and test environments"
    task :all do
      system("rake db:migrate")
      system("rake db:migrate RAILS_ENV=test")
    end
  end

  namespace :rollback do
    desc "Rolls the schema back to the previous version for development and test environments"
    task :all do
      system("rake db:rollback")
      system("rake db:rollback RAILS_ENV=test")
    end
  end
end