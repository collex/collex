class DevController < ApplicationController
   layout nil
   
   def parse
      
      if params[:rdf]
         tf = Tempfile.open("kowari")
         @url = "file://#{tf.path}"
         tf.puts(params[:rdf])
         tf.close
      else
         @url = params[:url]
      end
      
      @@kowari ||= Kowari.new

      temp_model = Kowari.model("temp")
      query = <<-QUERY
       create #{temp_model};
       delete select $s $p $o from #{temp_model}
                where $s $p $o from #{temp_model};
       load <#{@url}> into #{temp_model};
       select $s $p $o from #{temp_model} where $s $p $o;
       drop #{temp_model};
      QUERY

      logger.info query
      begin
         @result = @@kowari.query(query)
      rescue SOAP::FaultError => e
         @error = e
      end
   end
end
