class StatsController < ApplicationController
  layout "bare"
  
  def index
    @db_stats = {
      :sites => Site.find(:all, :order => "description ASC"),
      :interpretations => Interpretation.find(:all),
      :users => User.find(:all, :order => "username ASC")
    }
    
    solr = CollexEngine.new
    @solr_stats = {
      # TODO: rework these stats
#      :facets => solr.all_facets,
#      :username => solr.facet('username', [{:field => "collected", :value => "collected"}]),
#      :tag => solr.facet('tag', [{:field => "collected", :value => "collected"}]),
    }
  end
end
