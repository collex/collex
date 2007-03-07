class ExpressionConstraint < Constraint
  def to_s
    "#{operator}#{value}"
  end

  def to_hash
    {:type => :expression, :expression => value, :invert => inverted}
  end
end
