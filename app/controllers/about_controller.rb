class AboutController < ApplicationController
   layout 'nines'

   before_filter :init_view_options

   private
   def init_view_options
     @use_tabs = true
     @use_signin= true
     @site_section = :about
     @uses_yui = true
     return true
   end
   
end
