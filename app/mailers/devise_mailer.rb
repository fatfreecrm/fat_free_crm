class DeviseMailer < Devise::Mailer
  def template_paths
    ["devise_mailer"]
  end
end
