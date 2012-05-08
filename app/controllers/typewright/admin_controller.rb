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

class Typewright::AdminController <  Admin::BaseController
  def index
    @features = Typewright::TwFeaturedObject.all
  end

  # GET /features/1
  # GET /features/1.xml
  def show
	  @uri = params[:uri]
	  #text = "#{COLLEX_PLUGINS['typewright']['web_service_url']}/documents/export_corrected_text?uri=#{@uri}"
	  xml_url = "#{COLLEX_PLUGINS['typewright']['web_service_url']}/documents/export_corrected_gale_xml.xml?uri=#{@uri}"
	  path = "#{Rails.root}/tmp/#{@uri.gsub(/[^\d]/, '')}.xml"
	  #TODO-PER: There needs to be some mechanism for deleting these objects after they've been downloaded
	  `curl #{xml_url} > #{path}`
	  send_file path, :type=>"application/xml", :x_sendfile=>true
  end

  # POST /features
  # POST /features.xml
  def create
    create_update_feature(params )
  end

  # PUT /features/1
  # PUT /features/1.xml
  def update
    create_update_feature(params)
  end

  
  # Add or update a TypeWright featured object. If this is called as
  # an update, the feature ID will be set. 
  # 
  def create_update_feature( params )
    features = params['features']
    feature_id = params['id']
    
    begin
      # ensure that the resources is valid and cached
      uri = features['uri']
      if CachedResource.exists(uri) == false
        solr = Catalog.factory_create(false)
        hit = solr.get_object(uri)
        raise "Can't find URI" if hit == nil    
        CachedResource.add(uri)
      end
        
      # if primary is set to true, set all other features
      # except primary to false. There can be only one primary
      if features['primary'] == true
        sql = 'update tw_featured_objects set `primary` = 0'
        ActiveRecord::Base.connection.execute(sql)  
      end
      
      if feature_id.nil? 
        found = Typewright::TwFeaturedObject.where("uri = ?", uri)
        if found && found.length > 0
          raise "\"#{uri}\" already exists"
        end
        feature = Typewright::TwFeaturedObject.new 
      else
        feature = Typewright::TwFeaturedObject.find(feature_id)
      end
      feature.uri = uri
      feature.primary = (features['primary'] == "true")
      feature.disabled = (features['disabled'] == "true")
      feature.save!
     
      render( :partial => 'features', :locals => { :features =>  Typewright::TwFeaturedObject.all  } )  
      
    rescue Exception => msg
      logger.error("**** ERROR: Can't add new TypeWright feature: " + msg.message)
      flash = "Server error when adding new TypeWright feature: #{msg.message}"
      render( :text  => flash, :status  => :bad_request )
    end
  end
  
  # Delete a feature
  #
  def destroy
    feature = Typewright::TwFeaturedObject.find(params[:id])
    feature.destroy
    redirect_to :action => "index" 
  end

	def stats
		users = ::User.all
		@stats = Typewright::DocumentUser.get_stats(users)

	end
end