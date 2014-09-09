##########################################################################
# Copyright 2014 Applied Research in Patacriticism and the University of Virginia
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

namespace :search do


	desc "Convert old style of saved search to the new style"
	task :convert  => :environment do
		puts "Converting all saved searches..."
		all = Search.all
		all.each do |saved_search|
			constraint = []
			srt = saved_search.sort_by
			srt = 'year' if srt == 'Date'
			srt = 'author' if srt == 'Name'
			srt = 'title' if srt == 'Title'
			srt = '' if srt == 'Relevancy'
			constraint.push("srt=#{srt}") if srt.present?
			constraint.push("dir=#{saved_search.sort_dir}") if saved_search.sort_dir.present? && saved_search.sort_dir != 'Ascending'

			saved_search.constraints.each do |saved_constraint|
				if saved_constraint.is_a?(FreeCultureConstraint)
					constraint.push("o=freeculture")
				elsif saved_constraint.is_a?(FullTextConstraint)
					constraint.push("o=fulltext")
				elsif saved_constraint.is_a?(TypeWrightConstraint)
					constraint.push("o=typewright")
				elsif saved_constraint.is_a?(ExpressionConstraint)
					expression = saved_constraint[:value]
					if expression and expression.strip.size > 0
						expression = "-#{expression}" if saved_constraint[:inverted]
						constraint.push("q=#{expression}")
					end
				elsif saved_constraint.is_a?(FacetConstraint)
					fields = { archive: 'a', author: 'aut', discipline: 'discipline', editor: 'ed', genre: 'g', title: 't', year: 'y' }
					f = fields[saved_constraint[:fieldx].to_sym]
					v = saved_constraint[:value]
					v = "-#{v}" if saved_constraint[:inverted]
					constraint.push("#{f}=#{v}")
				elsif saved_constraint.is_a?(FederationConstraint)
					constraint.push("f=" + saved_constraint[:value])
				end # if saved_constraint.is_a
			end # end do
			puts "#{saved_search.name}: #{constraint.join("&")}"
			saved_search.url = constraint.join("&")
			saved_search.save!
		end
	end
end
