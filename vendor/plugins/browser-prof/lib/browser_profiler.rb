
module ActionController
  class Base
    alias_method(:unhooked_process,:process) unless self.respond_to? :unhooked_process
    def process(request,response, method = :perform_action, *arguments)
      params = request.params
      if (params.key?('browser_profile!') || params.key?('file_profile!')) && $profile_buf.nil?
				require 'ruby-prof'
				require 'ruby_prof/graph_html_printer_enhanced'
				$profile_buf, proc_out = '', nil
        results = RubyProf.profile { proc_out = unhooked_process(request,response, method = :perform_action, *arguments); }
#        puts "----",results.inspect
#        printer = RubyProf::FlatPrinter.new(result)
#        printer.print(STDOUT, 0)
        profiling = RubyProf::GraphHtmlPrinterEnhanced.new(results, true)
				output = params.key?('file_profile!') ? File.new("#{RAILS_ROOT}/log/profile_out.html","w") : $profile_buf
				profiling.print(output,0)
        proc_out
      else
        unhooked_process(request,response, method = :perform_action, *arguments)   
      end
    end
  end
  class CgiResponse
    alias_method :unhooked_out, :out
    def out(output = $stdout)
      if $profile_buf
        body.gsub!(/<\/body>.*$/mi,'')
        body << $profile_buf
        body << '</body></html>'
        $profile_buf = nil
      end
      unhooked_out(output)
    end
  end
end
