class Search < ActiveRecord::Base
  belongs_to :user
  has_many :constraints, :dependent => :destroy
  
  def to_solr_expression
    clauses = []
    constraints.each do |constraint|
      clauses << constraint.to_solr_expression
    end
    
    "(#{clauses.join(" AND ")})"
  end
  
  def to_s
    s = ""
    constraints.each do |constraint|
      s << "#{constraint}\n"
    end
    s
  end
end
