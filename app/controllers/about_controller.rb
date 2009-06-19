class AboutController < ApplicationController
  layout 'nines'

  before_filter :init_view_options

  private
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :about
    @uses_yui = true
    return true
  end
   
  # This is for the redirects from the old about pages.
  public
  def software
    do_redirect(params)
  end
  
  def scholarship
    do_redirect(params)
  end
  
  def community
    do_redirect(params)
  end
  
  private
  def do_redirect(params)
    headers["Status"] = "301 Moved Permanently"
    params[:page] = 'index' if !params[:page]
    redirect_to "/about/#{params[:action]}/#{params[:page]}.#{params[:ext]}"
  end
end
