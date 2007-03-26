class SolrBaseModel < ActiveRecord::Base
  # From: http://rails.techno-weenie.net/forums/2/topics/724
  self.abstract_class = true
  def create_or_update
    errors.empty?
  end
  
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  def self.solr
    CollexEngine.new
  end
  
end