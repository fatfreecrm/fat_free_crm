# frozen_string_literal: true

class WikidataJob < ApplicationJob
  queue_as :default

  def perform(account)
    WikidataService.new(account).call
  end
end
