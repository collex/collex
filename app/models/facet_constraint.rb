class FacetConstraint < Constraint
  def to_solr_expression
    "#{operator}#{field}:\"#{value}\""
  end
  
  def to_s
    "#{operator}#{field}:#{value}"
  end
end