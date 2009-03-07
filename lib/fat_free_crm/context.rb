module FatFreeCRM
  module Context

    def save_context(default_name)
      context = (params[:context].blank? ? default_name : params[:context])
      mark_context(context)
    end

    #----------------------------------------------------------------------------
    def mark_context(name)
      context = name.to_sym
      if params[:visible] == "true"
        session.data.delete(context)
      else
        session[context] = true
      end
      context
    end

    #----------------------------------------------------------------------------
    def drop_context(name)
      session.data.delete(name.to_sym)
    end

    #----------------------------------------------------------------------------
    def context_exists?(name)
      session[name.to_sym]
    end

  end
end

ActionView::Base.send(:include, FatFreeCRM::Context)
ActionController::Base.send(:include, FatFreeCRM::Context)

