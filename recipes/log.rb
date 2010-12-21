namespace :log do

  desc "Tail log files. Defaults to production.log. Set LOG=name.log to override"
  task :tail, :roles => :app do
    log_name = ENV['LOG'] || "production.log"
    sudo "tail -f #{shared_path}/log/#{log_name}" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

end
