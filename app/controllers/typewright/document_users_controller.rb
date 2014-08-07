# ------------------------------------------------------------------------
#     Copyright 2011 Applied Research in Patacriticism and the University of Virginia
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

class Typewright::DocumentUsersController < ApplicationController
	# DELETE /document_users/1
	def destroy
		# this doesn't destroy this document, just the user's connection to it.
		user = current_user
		if user == nil
			render :partial => '/typewright/widgets/my_documents', :locals => { :document_list => document_list }
			# TODO-PER: This should display a message about needing to be logged in.
			# render :text => "You must be signed in to use TypeWright"
		else
			user_doc = Typewright::DocumentUser.find_by_id(params[:id])
			user_doc.destroy if user_doc
		end
		document_list = Typewright::DocumentUser.document_list(Setup.default_federation(), user.id)
		render :partial => '/typewright/widgets/my_documents', :locals => { :document_list => document_list }
	end

#  # POST /user_docs
#  def create
#    @user_doc = UserDoc.new(params[:user_doc])
#
#    respond_to do |format|
#      if @user_doc.save
#        format.html { redirect_to(@user_doc, :notice => 'User doc was successfully created.') }
#        format.xml  { render :xml => @user_doc, :status => :created, :location => @user_doc }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @user_doc.errors, :status => :unprocessable_entity }
#      end
#    end
#  end
#
#	def login
#		federation = params[:federation]
#		user_id = params[:user_id]
#		user = User.find_by_federation_and_orig_id(federation, user_id)
#		if user == nil
#			user = User.create({:federation => federation, :orig_id => user_id})
#		end
#		session[:user_id] = user.id
#	end
end
