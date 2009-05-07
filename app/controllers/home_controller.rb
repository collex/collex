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
    threads = DiscussionThread.find(:all, :order => 'updated_at', :limit => '5')
    @discussions = []
    threads.each {|thread|
      @discussions.push({ :title => thread.title.length > 0 ? thread.title : "[Untitled]", :id => thread.id })
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
    @carousel = []
    for facet in facets
      @carousel.push({ :title => facet[:carousel_title], :description => facet[:carousel_description], :url => facet[:carousel_url], :image => facet.image ? facet.image.public_filename : '' })
    end
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
