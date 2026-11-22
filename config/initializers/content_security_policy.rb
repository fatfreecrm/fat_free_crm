# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, "https://*.gravatar.com", "https://*.openstreetmap.org"
    policy.object_src  :none
    policy.script_src  :self, :https, "https://unpkg.com"
    policy.style_src   :self, :https, :unsafe_inline, "https://unpkg.com"

    # Allow http for development
    if Rails.env.development?
      policy.default_src :self, :https, :http
      policy.font_src    :self, :https, :http, :data
      policy.img_src     :self, :https, :http, :data, "https://*.gravatar.com", "https://*.openstreetmap.org"
      policy.script_src  :self, :https, :http, "https://unpkg.com"
      policy.style_src   :self, :https, :http, :unsafe_inline, "https://unpkg.com"
    end

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = true
end
