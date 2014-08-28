##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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


  def self.role_field_names
    {
        'role_ARC' => { :display =>  'Architect' , :search_field => 'search_role_ARC' },
        'role_ART' => { :display =>  'Artist' , :search_field => 'search_artist' },
        'role_AUT' => { :display =>  'Author' , :search_field => 'ath' },
        'role_BKD' => { :display =>  'Book Designer' , :search_field => 'search_role_BKD' },
        'role_BKP' => { :display =>  'Book Producer' , :search_field => 'search_role_BKP' },
        'role_BND' => { :display =>  'Binder' , :search_field => 'search_role_BND' },
        'role_CLL' => { :display =>  'Calligrapher' , :search_field => 'search_role_CLL' },
        'role_CLR' => { :display =>  'Colorist' , :search_field => 'search_role_CLR' },
        'role_CMT' => { :display =>  'Compositor' , :search_field => 'search_role_CMT' },
        'role_COL' => { :display =>  'Collector' , :search_field => 'search_role_COL' },
        'role_COM' => { :display =>  'Compiler' , :search_field => 'search_role_COM' },
        'role_CRE' => { :display =>  'Creator' , :search_field => 'search_role_CRE' },
        'role_CTG' => { :display =>  'Cartographer' , :search_field => 'search_role_CTG' },
        'role_CWT' => { :display =>  'Commentator' , :search_field => 'search_role_CWT' },
        'role_DUB' => { :display =>  'Dubious Author' , :search_field => 'search_role_DUB' },
        'role_EDT' => { :display =>  'Editor' , :search_field => 'ed' },
        'role_FAC' => { :display =>  'Facsimilist' , :search_field => 'search_role_FAC' },
        'role_ILL' => { :display =>  'Illustrator' , :search_field => 'search_role_ILL' },
        'role_ILU' => { :display =>  'Illuminator' , :search_field => 'search_role_ILU' },
        'role_LTG' => { :display =>  'Lithographer' , :search_field => 'search_role_LTG' },
        'role_OWN' => { :display =>  'Owner' , :search_field => 'search_owner' },
        'role_PBL' => { :display =>  'Publisher' , :search_field => 'pub' },
        'role_POP' => { :display =>  'Printer of plates' , :search_field => 'search_role_POP' },
        'role_PRM' => { :display =>  'Printmaker' , :search_field => 'search_role_PRM' },
        'role_PRT' => { :display =>  'Printer' , :search_field => 'search_role_PRT' },
        'role_RBR' => { :display =>  'Rubricator' , :search_field => 'search_role_RBR' },
        'role_RPS' => { :display =>  'Repository' , :search_field => 'search_role_RPS' },
        'role_SCL' => { :display =>  'Sculptor' , :search_field => 'search_role_SCL' },
        'role_SCR' => { :display =>  'Scribe' , :search_field => 'search_role_SCR' },
        'role_TRL' => { :display =>  'Translator' , :search_field => 'search_role_TRL' },
        'role_TYD' => { :display =>  'Type Designer' , :search_field => 'search_role_TYD' },
        'role_TYG' => { :display =>  'Typographer' , :search_field => 'search_role_TYG' },
        'role_WDC' => { :display =>  'Wood Cutter' , :search_field => 'search_role_WDC' },
        'role_WDE' => { :display =>  'Wood Engraver' , :search_field => 'search_role_WDE' },
    }
  end

  
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
