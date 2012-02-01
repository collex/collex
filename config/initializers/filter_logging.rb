# This was for rails 3.2.1. Doesn't work in 3.1.3
# * skip "Rendered partial..." lines
#module ActiveSupport
#  class BufferedLogger
#    def add(severity, message = nil, progname = nil, &block)
#      return if @level > severity
#
#      # Skip "Rendered..." messages
#      if message =~ /^\s*Rendered.*/
#        return
#      end
#
#	  @log.add(severity, message, progname, &block)
#	end
#  end
#end
