##########################################################################
# Copyright 2007 Applied Research in Patacriticism
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

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
