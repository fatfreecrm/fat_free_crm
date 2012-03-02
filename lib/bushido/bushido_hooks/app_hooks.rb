class BushidoAppHooks < Bushido::EventObserver
  def app_claimed
    puts "Updating #{User.first.inspect} with incoming data #{params.inspect}"
    puts "Authlogic username column: #{::Authlogic::Cas.cas_username_column}="
    puts "Setting username to: #{params.try(:[], 'ido_id')}"

    user = User.first
    if user
      data = params['data']

      user.email      = data['email']
      user.first_name = user.email.split('@').first
      user.last_name  = user.email.split('@').last
      user.username   = data['email']
      user.deleted_at = nil
      user.send("#{::Authlogic::Cas.cas_username_column}=".to_sym, params['data'].try(:[], 'ido_id'))
      puts user.inspect
      user.save!
    end
  end
end
