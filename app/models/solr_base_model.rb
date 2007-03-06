class SolrBaseModel < ActiveRecord::Base
  # From: http://rails.techno-weenie.net/forums/2/topics/724

  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  def self.solr
    @solr ||= CollexEngine.new
  end
  
end