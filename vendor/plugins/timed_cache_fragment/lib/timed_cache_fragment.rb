# TimedCacheFragment
module ActionController
  module Cache
    module TimedCache
      #used to store the associated timeout time of cache key
      @@cache_timeout_values = {} 
      # TODO: this will not work well in a cluster environment
      # perhaps incorporate the timeout value into the fragment key .. or read the timestamp of the file?
      
      #handles standard ERB fragments used in RHTML
      def cache_timeout(name={}, expire = 10.minutes.from_now, &block)
        unless perform_caching then block.call; return end
        key = fragment_cache_key(name)
        if is_cache_expired?(key)
          expire_timeout_fragment(key)
          @@cache_timeout_values[key] = expire
        end
        cache_erb_fragment(block,name)
      end
      
      #handles the expiration of timeout fragment
      def expire_timeout_fragment(key)
        case
        when key.kind_of?(Regexp)
          @@cache_timeout_values.keys.each { |valid_key|
            if valid_key =~ key
              @@cache_timeout_values[valid_key] = nil 
              expire_fragment(valid_key)
            end
          }
        when (key.kind_of?(Hash) || key.kind_of?(String)) 
          valid_key = fragment_cache_key(key)
          @@cache_timeout_values[valid_key] = nil
          expire_fragment(valid_key)
        end  
      end
      
      #checks to see if a cache has fully expired
      def is_cache_expired?(name)
        key = fragment_cache_key(name)
        return true if @@cache_timeout_values[key].nil? or read_fragment(key).nil?
        return (@@cache_timeout_values[key] < Time.now)
      end
    end
  end
end

module ActionView
  module Helpers
    module TimedCacheHelper
      def is_cache_expired?(name = nil)
        return false if name.nil?
        key = fragment_cache_key(name)
        return @controller.send('is_cache_expired?', key)
      end
      def cache_timeout(name,expire=10.minutes.from_now, &block)
        @controller.cache_timeout(name,expire,&block)
      end
    end
  end
end

#add to the respective controllers
ActionView::Base.send(:include, ActionView::Helpers::TimedCacheHelper)
ActionController::Base.send(:include, ActionController::Cache::TimedCache)