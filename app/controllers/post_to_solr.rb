require 'net/http'

class TestHTTP
	def initialize(xml)
		postit(xml)
	end
	def postit(xml)
	
post = Net::HTTP::Post.new("/solr/update")
     post.body = xml
     post.content_type = 'application/x-www-form-urlencoded'
     response = Net::HTTP.start("localhost", "8983") do |http|
       http.request(post)
       end
        puts response
end

end


