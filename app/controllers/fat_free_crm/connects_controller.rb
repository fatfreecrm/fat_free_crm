# frozen_string_literal: true

module FatFreeCrm
  class ConnectsController < FatFreeCrm::ApplicationController

    def index
      redirect_to main_app.connect_streams_index_path
    end
  end
end