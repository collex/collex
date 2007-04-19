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
     
     @results = data.docs
     
     collectable_data = Solr::Util.paired_array_to_hash(data.data['collectable'])
     @results.each {|r| r.merge!(Solr::Util.paired_array_to_hash(collectable_data[r['uri']]))}
  end

  def add
    user = User.find_by_username(session[:user][:username])

     # extract the individual tags/keywords from the tag string entered by the user
     # currently split by whitespace, but TODO in the future this should be enhanced to
     # allow tags to be quoted, so that the string /"this is a single tag" and-so-is-this/ is parsed
     # as two tags instead of six
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
          end
        end
     end     

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
