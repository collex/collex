# * skip "Rendered partial..." lines
module ActiveSupport
  class BufferedLogger
    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity

      # Skip "Rendered..." messages
      if message =~ /^\s*Rendered.*/
        return
      end

	  @log.add(severity, message, progname, &block)
		if message =~ /^Completed.*/
			flush()
		end
	end
  end
end