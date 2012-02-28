class BushidoUserHooks < Bushido::EventObserver
  def user_added
    puts "Adding a new user with incoming data #{params.inspect}"
    puts "Authlogic username column: #{::Authlogic::Cas.cas_username_column}="
    puts "Setting username to: #{params['data'].try(:[], 'ido_id')}"

    data = params['data']
    
    user = User.unscoped.find_or_create_by_ido_id(data['ido_id'])

    user.email      = data['email']
    user.first_name = user.email.split('@').first
    user.last_name  = user.email.split('@').last
    user.username   = data['email']
    user.deleted_at = nil
    user.send("#{::Authlogic::Cas.cas_username_column}=".to_sym, data.try(:[], 'ido_id'))

    puts user.inspect

    user.save!
  end

  def user_removed
    puts "Removing user based on incoming data #{params.inspect}"
    puts "Authlogic username column: #{::Authlogic::Cas.cas_username_column}="

    user = User.unscoped.find_by_ido_id(params['data']['ido_id'])

    # TODO: Disable the user instead of destroying them (to prevent data loss)
    user.try(:destroy)
  end

  def user_updated
    puts "Updating user based on incoming data #{params.inspect}"
    puts "Authlogic username column: #{::Authlogic::Cas.cas_username_column}="

    data = params['data']
    user = User.unscoped.find_by_ido_id(data['ido_id'])

    if user
      # Re-use the CAS login method to set all the extra attributes we
      # care about (first_name, last_name, email, local, timezone,
      # etc.)
      user.bushido_extra_attributes(data)
      user.save
    end
  end
end
