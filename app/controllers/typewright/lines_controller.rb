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
   # PUT /typewright/lines/1
   def update
      # this is called whenever the user corrects a line.
      user_id = get_curr_user_id()
      if !user_id
         render :text => 'You must be signed in to correct lines. Did your session expire?', :status => :bad_request
      else
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
            render :text => 'Illegal parameters.', :status => :bad_request
         else
            rec = Typewright::Line.get_undoable_record(doc_id, page, line, user_id, src)
            if rec
               rec.destroy()
            end
            if status != 'undo'
               Typewright::Line.create({ :user_id => user_id, :document_id => doc_id, :page => page, :line => line, :status => status, :words => Typewright::Line.words_to_db(words), :src => src, box: box })
            end

            render :text => ""
         end
      end
   end

end
