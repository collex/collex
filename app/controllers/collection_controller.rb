##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
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

TAG_INSTRUCTIONS = 'one-word keywords'
ANNOTATION_INSTRUCTIONS = 'your annotations'

class CollectionController < ApplicationController
  before_filter :authorize
  layout nil
  
  def collect
    urls = []
    params.each do |key, value|
      if key =~ /^url/
        urls << value
      end
    end

     data = COLLEX_MANAGER.objects_behind_urls(urls, session[:user][:username])
     
     @results = data
     @results.each do |r|
       # map user specific fields to something friendlier for the view
       r['tag'] = r["#{session[:user][:username]}_tag"]
       r['annotation'] = r["#{session[:user][:username]}_annotation"]
       
       #TODO implement fetching "tag" from Solr - careful though, storing it causes CollexEngine#add to need a contortion
       r['all_tags'] = []
     end
  end

  def add
    user = User.find_by_username(session[:user][:username])

     # extract the individual tags/keywords from the tag string entered by the user
     # currently split by whitespace, but TODO in the future this should be enhanced to
     # allow tags to be quoted, so that the string /"this is a single tag" and-so-is-this/ is parsed
     # as two tags instead of six
     solr = CollexEngine.new
     params.each do |key,value|
        match = /^tags-(.*)/.match(key.to_s)
        if match
          if value != TAG_INSTRUCTIONS
            uri = match[1]
            tags = value
            annotation = params["notes-#{uri}"]
            annotation = "" if annotation == ANNOTATION_INSTRUCTIONS
            
            interpretation = user.interpretations.find_by_object_uri(uri)
            if not interpretation
              interpretation = Interpretation.new(:object_uri => uri)
              user.interpretations << interpretation
            end
            interpretation.annotation =  annotation
            interpretation.tag_list = tags
            interpretation.save!
            solr.update(user.username, uri, interpretation.tags.collect { |tag| tag.name }, interpretation.annotation)
          end
        end
     end     
     solr.commit

     render_text <<-CLOSE
       <html>
         <head>
           <script type="text/javascript">
             window.close();
           </script>
         </head>
       </html>
     CLOSE
  end
    
end
