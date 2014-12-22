# ------------------------------------------------------------------------
#     Copyright 2010 Applied Research in Patacriticism and the University of Virginia
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
class Admin::FeaturesController < Admin::BaseController

	# GET /features
	# GET /features.xml
	def index
		@features = FeaturedObject.all
		ss = self.class.helpers.get_saved_searches(current_user.username)
		@saved_searches = []
		ss.each {|rec|
			@saved_searches.push({ :value => rec.name, :text => rec.name })
		}
	end

	# POST /features
	# POST /features.xml
	def create
		set_object(nil, params[:image], params[:features])
	end

	# PUT /features/1
	# PUT /features/1.xml
	def update
		set_object(params[:id], params[:image], params[:features])
	end

	# DELETE /features/1
	# DELETE /features/1.xml
	def destroy
		@features = FeaturedObject.find(params[:id])
		@features.destroy

		respond_to do |format|
			format.html { redirect_to(:action => 'index') }
			format.xml  { head :ok }
		end
	end

	private
	def get_hit_item(hit, label)
		arr = hit[label]
		return "" if arr == nil || arr.length == 0
		if arr.kind_of?(Array)
			return arr[0]
		else
			return arr
		end
	end

	def set_object(id, p_image, p_obj)
		begin
			type = 'creating'
			raise "No parameters passed in" if p_obj == nil
			# The difference between creating a new one and modifying an old one is just if an id was passed.
			if id && id.to_i > 0
				type = 'modifying'
			end
			p_obj[:disabled] = '0' if p_obj[:disabled] == nil
			uri = p_obj[:object_uri]
			hit = CachedResource.get_hit_from_uri(uri)
			if hit == nil
				solr = Catalog.factory_create(false)
				hit = solr.get_object(uri)
			end
			raise "Can't find URI" if hit == nil
			p_obj[:title] = get_hit_item(hit, 'title')
			p_obj[:object_url] = get_hit_item(hit, 'url')
			p_obj[:date] = get_hit_item(hit, 'date_label')
			site = Catalog.factory_create(false).get_archive(get_hit_item(hit, 'archive'))
			p_obj[:site] = site['name']
			p_obj[:site_url] = site['site_url']

			if type == 'modifying'
				feature = FeaturedObject.find(id)
				feature.update_attributes!(p_obj)
			else
				feature = FeaturedObject.new(p_obj)
				feature.save!
			end

			err = Image.save_image(p_image, feature)
			case err[:status]
				when :error then
					flash = err[:user_error]
					logger.error(err[:log_error])
				when :saved then
					flash = "OK:#{feature.id}"
				when :no_image then
					flash = "OK:#{feature.id}"
			end
#			image = nil
#			if p_image && p_image.length > 0
#				image = Image.new({ :uploaded_data => p_image })
#				feature.image = image
#			end
#			err = false
#			if feature.save
#				begin
#					feature.image.save! if image	# don't resave if there wasn't a change.
#				rescue
#					err = true
#					feature.delete if type == 'creating'
#					flash = "ERROR: The image you have uploaded is too large or of the wrong type.<br />The file name must end in .jpg, .png or .gif, and cannot exceed 1MB in size."
#				end
#				if err == false
#					flash = "OK:#{feature.id}"
#				end
#			else
#				flash = "Error #{type} feature"
#			end
		rescue Exception => msg
			logger.error("**** ERROR: Can't #{type} feature: " + msg.message)
			logger.error msg.backtrace.join("\n")
			flash = "Server error when #{type} feature: #{msg.message}"
		end
		flash = flash.gsub("\n", '<br />')
		flash = flash.gsub("'") { |apos| "&apos;" }
	    render :text => respond_to_file_upload("stopFeatureUpload", flash) # This is loaded in the iframe and tells the dialog that the upload is complete.
	end
end
