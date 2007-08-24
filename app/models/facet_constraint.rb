class FacetConstraint < Constraint
  def to_solr_expression
    if value == '<unspecified>'
      "#{inverted ? '' : '-'}#{field}:[* TO *]"
    else 
      "#{operator}#{field}:\"#{value}\""
    end
  end
  
  def to_s
    "#{operator}#{field}:#{value}"
  end
end