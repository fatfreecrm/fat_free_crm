# frozen_string_literal: true

class Passkey < ActiveRecord::Base
  belongs_to :user
end
