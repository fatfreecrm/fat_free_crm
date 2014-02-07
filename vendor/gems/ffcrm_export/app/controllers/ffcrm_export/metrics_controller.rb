require_dependency "ffcrm_export/application_controller"

module FfcrmExport
  class MetricsController < ApplicationController
    def index
      respond_to do |format|
        format.csv { render text: FfcrmExport::CsvExporter.dump(params[:date]) }
      end
    end
  end
end
