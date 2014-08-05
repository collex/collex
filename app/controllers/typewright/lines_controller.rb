# ------------------------------------------------------------------------
#     Copyright 2011 Applied Research in Patacriticism and the University of
# Virginia
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------
class Typewright::LinesController < ApplicationController
	# PUT /typewright/lines/1.json
	def update
		# this is called whenever the user corrects a line.
		# it is called when the user leaves the page, too, with the parameter :unload set.
		respond_to do |format|
			format.json {
				user_id = get_curr_user_id()
				if !user_id
					render :json => {message: 'You must be signed in to correct lines. Did your session expire?'}, :status => :bad_request
				else
					if params[:unload].present?
						unload(params)
					elsif params[:ping].present?
						ping(user_id, params)
					else
						update_line(user_id, params)
					end
				end
			}
		end
	end

	private
	def unload(params)
		token = params[:token]
		Typewright::Overview.unload_doc(token)
		render json: {}
	end

	def adjust_line_numbers(arr)
		# TODO-PER: I don't know why the line numbers are off-by-one coming from the Typewright server.
		arr.each { |rec|
			rec['line'] = rec['line'].to_f - 1 if rec['line'].end_with?('.0')
		}
	end

	def ping(user_id, params)
		token = params[:token]
		document_id = params[:document_id]
		page = params[:page]
		load_time = params[:load_time]
		typewright_user_id = Typewright::User.get_or_create_user(Setup.default_federation(), user_id, user.username)
		typewright_user_id = typewright_user_id.id if typewright_user_id
		data = Typewright::Line.since(token, typewright_user_id, document_id, page, load_time)
		adjust_line_numbers(data['lines'])
		render json: data
	end

	def update_line(user_id, params)
		token = params[:token]
		doc_id = params[:id]
		passed = JSON.parse(params[:params])
		src = passed['src']
		page = passed['page']
		line = passed['line'] ? passed['line'].to_f : nil
		user_id = Typewright::User.get_or_create_user(Setup.default_federation(), user_id, user.username)
		user_id = user_id.id if user_id
		status = passed['status']
		words_changes = passed['words']
		words = nil
		words = words_changes[words_changes.length-1] if !words_changes.nil?
		box = passed['box']
		if doc_id == nil || page == nil || line == nil || user_id == nil || status == nil || src == nil
			render :json => {message: 'Illegal parameters.'}, :status => :bad_request
		else
			rec = Typewright::Line.get_undoable_record(doc_id, page, line, user_id, src)
			if rec
				rec.destroy()
			end
			ret = nil
			if status == 'undo'
				ret = Typewright::Line.since(token, user_id, doc_id, page)
				more_recent_corrections = ret[:changes]
				editors = ret[:editors]
			else
				ret = Typewright::Line.create({:token => token, :user_id => user_id, :document_id => doc_id, :page => page, :line => line, :status => status, :words => Typewright::Line.words_to_db(words), :src => src, box: box})
				more_recent_corrections = ret.attributes['changes']
				editors = ret.attributes[:editors].map { |rec| { user_id: rec.user_id, last_contact_time: rec.last_contact_time, username: rec.username, federation: rec.federation, federation_user_id: rec.federation_user_id } }
			end

			more_recent_corrections = more_recent_corrections.map { |rec| rec.attributes.to_options! }
			more_recent_corrections = Typewright::Line.convert_from_server_to_usable(more_recent_corrections)
			adjust_line_numbers(more_recent_corrections)
			render :json => { lines: more_recent_corrections, editors: editors }
		end
	end
end
