namespace :crm do
  desc "Email dropbox check action"
  task :dropbox => :environment do
    crawler = FatFreeCRM::Dropbox.new
    crawler.run
  end
end