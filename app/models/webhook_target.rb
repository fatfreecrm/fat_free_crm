# frozen_string_literal: true

class WebhookTarget < ActiveRecord::Base
  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
end
