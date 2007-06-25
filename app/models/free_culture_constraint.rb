class FreeCultureConstraint < ExpressionConstraint
  def to_solr_expression
    "#{operator}freeculture:[* TO *]"
  end
  
  def to_s
    "#{operator}?:freeculture:[* TO *]"
  end
end
