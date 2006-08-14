module WebUtils
   # Fetch method copied from PickAxe, p. 700
   def WebUtils.fetch_html(url, limit=10)
      fail 'http redirect too deep' if limit.zero?
      
      response = Net::HTTP.get_response(URI.parse(url))
      
      case response
         when Net::HTTPSuccess
            response
         when Net::HTTPRedirection
            fetch_html(response['location'], limit - 1)
         else
            response.error!
      end
   end   
end
