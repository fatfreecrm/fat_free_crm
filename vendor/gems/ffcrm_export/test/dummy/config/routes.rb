Rails.application.routes.draw do

  mount FfcrmExport::Engine => "/ffcrm_export"
end
