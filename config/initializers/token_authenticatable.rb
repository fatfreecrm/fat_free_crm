Warden::Strategies.add(:token_authenticatable) do
  def valid?
    params[:authentication_credentials].present?
  end

  def authenticate!
    token = params[:authentication_credentials]
    user = User.find_by(authentication_token: token)
    if user
      success!(user)
    else
      fail!("Invalid authentication token")
    end
  end
end
