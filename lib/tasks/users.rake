##########################################################################
# Copyright 2012 Applied Research in Patacriticism and the University of Virginia
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

namespace :users do
	require 'csv'

	def each_row(fname, max_recs = nil)
		max_recs = 99999 if max_recs == nil
		max_recs = max_recs.to_i
		# This reads the file as CSV and calls the block passed to it with each row. The row is returned as a hash with the column name as the key.
		# Therefore, we don't have to worry about the column positions outside of this function.
		is_first = true
		col_names = []
		count = 0
		CSV.foreach(fname, :encoding => 'u') do |row|
			if is_first
				row.each {|col|
					col_names.push("#{col}")
				}
				is_first = false
			else
				h = {}
				col_names.each_with_index { |col, i|
					h[col.strip().gsub(/\s+/, ' ')] = "#{row[i]}".gsub(/\s+/, ' ')
				}
				yield(h, count)
				count += 1
				return if count >= max_recs
			end
		end
	end

	desc "Find users in batch from csv file (file=path)"
	task :batch_find  => :environment do
		path = ENV['file']
		if path.blank?
			puts "Usage: rake users:batch_find file=path"
			return
		end

	  puts "Find existing users for the rows in #{path}..."
		# the file needs to be CSV and have the columns: id,"username","password_hash","fullname","email","institution","link","about_me",image_id,"hide_email"

		puts "typewright-orig-id,18thconnect-id,name,email"
		each_row(path) { |row, count|
			id = row['id']
			name = row['username']
			email = row['email']
			user = User.find_by_username(name)
			user = User.find_by_email(email) if user.blank?
			if !user.blank?
				puts "#{id},#{user.id},#{name},#{email}"
			end
		}

	end

	desc "Creates new users in batch from csv file (file=path)"
	task :batch_create  => :environment do
		path = ENV['file']
		if path.blank?
			puts "Usage: rake users:batch_create file=path"
			return
		end
		
	  puts "Create users for all the rows in #{path}..."
		# the file needs to be CSV and have the columns: id,"username","password_hash","fullname","email","institution","link","about_me",image_id,"hide_email"

		each_row(path) { |row, count|
			name = row['username']
			email = row['email']
			user = User.find_by_username(name)
			user = User.find_by_email(email) if user.blank?
			if user.blank?
				cols = { username: row['username'],
					password_hash: row['password_hash'],
					email: row['email']
				}
				cols[:fullname] = row['fullname'] if row['fullname'] != 'NULL'
				cols[:institution] = row['institution'] if row['institution'] != 'NULL'
				cols[:link] = row['link'] if row['link'] != 'NULL'
				cols[:about_me] = row['about_me'] if row['about_me'] != 'NULL'
				cols[:hide_email] = row['hide_email'] if row['hide_email'] != 'NULL'

				user = User.create!(cols)
				puts "tw id: #{row['id']} new_id: #{user.id} #{name} = #{email}"
			end
		}

	end
end
