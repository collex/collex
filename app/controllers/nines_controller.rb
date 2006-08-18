class NinesController < ApplicationController
  layout 'popup'
  
  def sites
    @sites = Site.find(:all, :order => "description ASC")
  end
end
