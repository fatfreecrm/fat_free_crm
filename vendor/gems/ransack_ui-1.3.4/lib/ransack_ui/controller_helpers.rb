module RansackUI
  module ControllerHelpers
    # Builds @ransack_search object from params[:q]
    # Model class can be passed in or inferred from controller name.
    #
    # Should be used as a before_filter, e.g.:
    #    before_filter :load_ransack_search, :only => :index
    #
    # Can also be called as a function if needed. Will return the search object.
    #
    def load_ransack_search(klass = nil)
      klass ||= controller_path.classify.constantize
      @ransack_search = klass.ransack(params[:q])
      @ransack_search.build_grouping if @ransack_search.groupings.empty?
      @ransack_search
    end
  end
end
