namespace :crm do
  namespace :dropbox do
    
    desc "Run dropbox crawler and process incoming emails"
    task :run => :environment do
      crawler = FatFreeCRM::Dropbox.new
      crawler.run
    end
    
    desc "Set up email dropbox based on currently loaded settings"
    task :setup => :environment do
      crawler = FatFreeCRM::Dropbox.new
      crawler.setup
    end
    
  end
end