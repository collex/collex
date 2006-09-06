TAG_INSTRUCTIONS = 'tag this item'
ANNOTATION_INSTRUCTIONS = 'annotate this item'

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

     @results = COLLEX_MANAGER.objects_behind_urls(urls, @session[:user][:username])
  end

  def add
    user = User.find_by_username(session[:user][:username])

     # extract the individual tags from the tag string entered by the user
     # currently split by whitespace, but TODO in the future this should be enhanced to
     # allow tags to be quoted, so that the string /"this is a single tag" and-so-is-this/ is parsed
     # as two tags instead of six
     @request.params.each do |key,value|
        match = /^tags-(.*)/.match(key.to_s)
        if match
          if value[0] != TAG_INSTRUCTIONS
            uri = match[1]
            tags = value[0]
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
