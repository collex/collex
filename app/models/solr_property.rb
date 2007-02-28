class SolrProperty < SolrBaseModel
  belongs_to :solr_resource
  
  column :name,  :string
  column :value, :string
  
  
end
