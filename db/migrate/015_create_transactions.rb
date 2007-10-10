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

class CreateTransactions < ActiveRecord::Migration
  def self.up
  	create_table :transactions do |t|
  	  t.column :process_id,	:integer,	:null => false
  	  t.column :item, 		:string, 	:null => false
  	  t.column :uri,		:string, 	:null => false
  	  t.column :stamp,		:datetime,	:null => false
  	  end
  end

  def self.down
  	drop_table :transactions
  end
end
