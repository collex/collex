class HomeController < ApplicationController

  layout 'collex_tabs'
  before_filter :init_view_options
  
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :home
    return true
  end
  
  def index
    @sites = Site.find(:all, :order => "description ASC")
  end

end
