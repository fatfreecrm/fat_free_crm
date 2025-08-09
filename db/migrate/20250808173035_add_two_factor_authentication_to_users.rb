# frozen_string_literal: true

class AddTwoFactorAuthenticationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :consumed_timestep, :integer
    add_column :users, :otp_required_for_login, :boolean
  end
end
