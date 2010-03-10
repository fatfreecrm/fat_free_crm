namespace :crm do
  namespace :dropbox do
    
    desc "Email dropbox check action"
    task :run => :environment do
      crawler = FatFreeCRM::Dropbox.new
      crawler.run
    end
    
    desc "Email dropbox setup"
    task :setup => :environment do
      crawler = FatFreeCRM::Dropbox.new
      crawler.setup
    end
    
  end
end