class HomeController < ApplicationController

  layout 'collex_tabs'
  before_filter :init_view_options
  
  def init_view_options
    @use_tabs = true
    @use_signin= true
    @site_section = :home
    return true
  end
  
  def index
    @sites = Site.find(:all, :order => "description ASC")
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
