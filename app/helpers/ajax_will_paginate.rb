class AjaxWillPaginate < WillPaginate::LinkRenderer

  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

  protected
  # "Ajaxify" page links by using :link_to_remote instead of :link_to. Also 
  # remove action part from the url, so it always points to :index and looks
  # like /controller?page=N
  #----------------------------------------------------------------------------
  def page_link(page, text, attributes = {})
    @template.link_to_remote(text, { 
      :url     => url_for(page).sub(/(\w+)\/\w+\?/, "\\1?"),
      :method  => :get,
      :loading => "$('loading').show()",
      :success => "$('loading').hide()"
    }.merge(@remote))
  end

end