class ExpressionConstraint < Constraint
  def to_solr_expression
    "#{operator}(#{value})"
  end
  
  def to_s
    "#{operator}?:#{value}"
  end
end
