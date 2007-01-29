require "erb"

module RubyProf
  # Generates graph[link:files/examples/graph_html.html] profile reports as html. 
  # To use the grap html printer:
  #
	# 	result = RubyProf.profile do
  #			[code to profile]
  #		end
  #
  # 	printer = RubyProf::GraphHtmlPrinter.new(result, 5)
  # 	printer.print(STDOUT, 0)
  #
  # The constructor takes two arguments.  The first is
  # a RubyProf::Result object generated from a profiling
  # run.  The second is the minimum %total (the methods 
  # total time divided by the overall total time) that
  # a method must take for it to be printed out in 
  # the report.  Use this parameter to eliminate methods
  # that are not important to the overall profiling results.
	#  
	#  This is mostly from ruby_forge, with some optimization changes.
  
  class GraphHtmlPrinterEnhanced
	  PERCENTAGE_WIDTH = 8
	  TIME_WIDTH = 10
	  CALL_WIDTH = 20
		MIN_TIME = 0.01
    MIN_THREAD_TIME = 0.0
	  
	
  	# Create a GraphPrinter.  Result is a RubyProf::Result	
  	# object generated from a profiling run.
    def initialize(result, sort_by_self = false)
 	    @result = result
      @sort_by_self = sort_by_self
 	  end

		def sort_methods(methods)
      return [] unless methods
			sorted_methods = methods.select {|name, method| method.total_time >= MIN_TIME }

			#sort methods by total_time
			if @sort_by_self
			   sorted_methods = sorted_methods.sort_by { |name, method| method.self_time}
			else
  			 sorted_methods = sorted_methods.sort_by { |name, method| method.total_time}
  		end
			
			#reverse the sort
			sorted_methods.reverse!

			sorted_methods
		end

		def sort_threads(threads)
			sorted_threads = threads.select {|thread_id, methods| @result.toplevel(thread_id).total_time >= MIN_THREAD_TIME }
		  sorted_threads	
		end

  	# Print a graph html report to the provided output.
  	# 
  	# output - Any IO oject, including STDOUT or a file. 
  	# The default value is STDOUT.
  	# 
  	# min_percent - The minimum %total (the methods 
  	# total time divided by the overall total time) that
  	# a method must take for it to be printed out in 
  	# the report. Default value is 0.
 	  def print(output = STDOUT, min_percent = 0)
      @output = output
      @min_percent = min_percent
      
      _erbout = @output
      erb = ERB.new(template, nil, nil)
      @output << erb.result(binding)
    end

    # These methods should be private but then ERB doesn't
    # work.  Turn off RDOC though 
    #--
    def total_time(thread_id)
			toplevel = @result.toplevel(thread_id)
			total_time = toplevel.total_time
			#total_time = 0.01 if total_time == 0
			return total_time
    end
   
    def total_percent(method)
      overall_time = self.total_time(method.thread_id)
      if overall_time != 0
        (method.total_time/overall_time) * 100
      else
        overall_time
      end
    end
    
    def self_percent(method)
      overall_time = self.total_time(method.thread_id)
      if overall_time != 0
			  (method.self_time/overall_time) * 100
			else
			  overall_time
		  end
    end

    # Creates a link to a method.  Note that we do not create
    # links to methods which are under the min_perecent 
    # specified by the user, since they will not be
    # printed out.
		def create_link(thread_id, name)
      # Get method
      method = @result.threads[thread_id][name]
      
      if self.total_percent(method) < @min_percent
        # Just return name
        name
      else
        # Create link
        "<a href=\"##{link_name(thread_id, name)}\">#{name}</a>" 
			end
  	end
  	
		def link_name(thread_id, name)\
    	name.gsub(/[><#\.\?=:]/,"_") + "_" + thread_id.to_s
  	end
    
 	  def template
			return IO.read(File.dirname(__FILE__) + "/template.rhtml")
		end
  end
end	

