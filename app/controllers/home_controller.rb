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
    @use_tabs = true
    @use_signin= true
    @site_section = :home
     @uses_yui = true
    return true
  end
  
  def redirect_to_index
    redirect_to :controller => 'home', :action => 'index'
  end
  
 def redirect_to_tag_cloud_update
    redirect_to  '/tagCloudUpdate.html'
  end

  def index
    #@sites = Site.find(:all, :order => "description ASC")

		threads = []
		topics = DiscussionTopic.get_all_with_date()
		for topic_arr in topics
			topic = topic_arr[:topic_rec]
			threads += topic.discussion_threads
		end
		threads = threads.sort {|a,b|
			b.discussion_comments[b.discussion_comments.length-1].updated_at <=> a.discussion_comments[a.discussion_comments.length-1].updated_at
		}
		threads = threads.slice(0..4)

		#threads = DiscussionThread.find(:all, :order => 'number_of_views desc', :limit => '5')
    @discussions = []
    threads.each {|thread|
      @discussions.push({ :title => thread.get_title().length > 0 ? thread.get_title() : "[Untitled]", :id => thread.id })
    }
    
    cloud_info = CachedResource.get_tag_cloud_info(nil) # get all tags and their frequencies
    @tags = cloud_info[:cloud_freq].sort {|a,b| b[1] <=> a[1]} # sort by frequency
    total_tags_wanted = @tags.length > 40 ? 40 : @tags.length
    total_bigger_tags = total_tags_wanted / 5
    @tags = @tags.slice(0, total_tags_wanted)  # we just want the top 40 tags.
    0.upto(total_bigger_tags-1) { |i| # now make a few of the tags larger
      @tags[i][2] = true
    }
    total_bigger_tags.upto(total_tags_wanted-1) { |i| # now make a few of the tags larger
      @tags[i][2] = false
    }
    @tags = @tags.sort {|a,b| a[0] <=> b[0]}  # now sort by tag name for display
    
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
