##########################################################################
# Copyright 2009 Applied Research in Patacriticism and the University of Virginia
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

class HomeController < ApplicationController

  layout 'nines'
  before_filter :init_view_options
  
  def init_view_options
    @site_section = :home
    return true
  end
  
  def redirect_to_index
    redirect_to :controller => 'home', :action => 'index'
  end
  
 def redirect_to_tag_cloud_update
    redirect_to  '/tagCloudUpdate.html'
  end

  def index

    @discussions = DiscussionTopic.get_most_popular(5)

	if Setup.site_name() == '18thConnect'
		@featured_news = true
	end
	  features = FeaturedObject.find_all_by_disabled('0')
	  if features.length > 0
		  features = features.sort_by {rand}
		  @feature = features[0]
	  end
    
	#@tags = CachedResource.get_most_popular_tags(40)
	@tags = CachedResource.get_most_recent_tags(40)
    
    # carousel
	@carousel = Catalog.factory_create(false).get_carousel()
	@carousel = @carousel.sort_by {rand}
	
#    facets = FacetCategory.find_all_by_carousel_include(1)
#		facets = facets.sort_by {rand}
#    @carousel = []
#    for facet in facets
#      title = facet[:value]
#      url = facet[:carousel_url]
#      if facet[:type] == 'FacetValue'
#        site = Site.find_by_code(title)
#		if site
#			title = site.description
#			url = site.url
#		else
#			title = "ERR: site not found:#{title}"
#		end
#      end
#      @carousel.push({ :title => title, :description => facet[:carousel_description], :url => url, :image => facet.image_id ? "/#{facet.image.photo.url}" : '' })
#	end
	respond_to do |format|
		format.html # index.html.erb
	end
    end
  
  def get_footer_data
    render :partial => 'footer_data'
  end
  
  def news
    @site_section = :news
#		render :template => '/about/news'
  end

  def atom
    # This redirects the old atom feeds
     render :text => <<-CLOSE
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
 
 <title>nines.org</title>
 <subtitle>Nineteenth Century Studies Online.</subtitle>
 <link href="http://nines.org" rel="self"/>
  <id>urn:uuid:60a0000-d399-11d9-b91C-0003939e0af6</id>
 
 <entry>
   <title>NINES has been reworked!</title>
   <link href="http://nines.org"/>
   <id>urn:uuid:1005c695-cfb8-4ebb-aaaa-80da344efa6a</id>
   <summary>Click http://nines.org to see the new NINES interface.</summary>
 </entry>
 
</feed>
     CLOSE
  end
  
	def wrapper
		if params[:style] == 'post'
			@current_page = "News"
			@site_section = :news
		else
			@current_page = "About"
			@site_section = :about
		end
		render :partial => "/layouts/wrapper"
	end
end
