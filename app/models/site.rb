class Site < ActiveRecord::Base
  def self.for_code(code)
    cache_sites
    @@site_cache[code]
  end
  
  def self.cache
    cache_sites
    @@site_cache
  end
  
private
  def self.cache_sites
    @@site_cache ||= nil
    if not @@site_cache
      sites = find(:all)
      @@site_cache = {}
      sites.each do |site|
        @@site_cache[site.code] = site
      end
    end
  end
end
