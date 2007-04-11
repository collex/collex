class AdminMessageController < ApplicationController
  before_filter :allow_only_local

  def add_site
    site = Site.find_by_code(params[:code])
    if site
      render :text => "SITE_ALREADY_EXISTS"
    else
      site = Site.new(:code => params[:code], :url => params[:url], :description => params[:description], :thumbnail => params[:thumbnail])
      site.save!
      render :text => "OK"
    end
  end

  private
  def allow_only_local
    if !(local_request?)
      render :text => "Only local requests supported", :status => 401
      return false
    end
  end

end
