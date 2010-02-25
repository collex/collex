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
    
	@tags = CachedResource.get_most_popular_tags(40)
    
    # carousel
    facets = FacetCategory.find(:all, :conditions => ['carousel_include = 1'])
		facets = facets.sort_by {rand}
    @carousel = []
    for facet in facets
      title = facet[:value]
      url = facet[:carousel_url]
      if facet[:type] == 'FacetValue'
        site = Site.find_by_code(title)
        title = site.description
        url = site.url
      end
      @carousel.push({ :title => title, :description => facet[:carousel_description], :url => url, :image => facet.image ? facet.image.public_filename : '' })
			end
    end
  
  def get_footer_data
    render :partial => 'footer_data'
  end
  
  def news
    @site_section = :news
		render :template => '/about/news'
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
end
