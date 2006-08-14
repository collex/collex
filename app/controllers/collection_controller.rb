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
     username = @session[:user][:username]

     # extract the individual tags from the tag string entered by the user
     # currently split by whitespace, but TODO in the future this should be enhanced to
     # allow tags to be quoted, so that the string /"this is a single tag" and-so-is-this/ is parsed
     # as two tags instead of six
     collectables = {}
     @request.params.each do |key,value|
        match = /^tags-(.*)/.match(key.to_s)
        if match
          if value[0] != TAG_INSTRUCTIONS
            uri = match[1]
            tags = value[0].downcase.split
            annotation = params["notes-#{uri}"]
            annotation = "" if annotation == ANNOTATION_INSTRUCTIONS
            collectables[uri] = {:tags => tags, :annotation => annotation}
          end
        end
     end     

     logger.info "Before COLLECTION.ADD: #{username} : #{collectables.to_yaml}"
     COLLEX_MANAGER.add(username, collectables)
     logger.info "After COLLECTION.ADD: #{username} : #{collectables.to_yaml}"

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
