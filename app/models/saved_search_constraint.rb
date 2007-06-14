class SavedSearchConstraint < Constraint
  def to_solr_expression
    User.find_by_username(self.field).searches.find_by_name(self.value).to_solr_expression
  end
  
  def to_s
    "?:#{self.to_solr_expression}"
  end
end