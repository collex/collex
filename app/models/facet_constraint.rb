class FacetConstraint < Constraint
  def to_s
    <<-VALUE
    #{operator}#{field}:"#{value}"
VALUE
  end
  
  def to_hash
    {:type => :facet, :field => field, :value => value, :invert => inverted}
  end
end