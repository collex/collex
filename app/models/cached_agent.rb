class CachedAgent < ActiveRecord::Base
  belongs_to :agent_type
  belongs_to :cached_document
end
