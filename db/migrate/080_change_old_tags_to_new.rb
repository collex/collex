class ChangeOldTagsToNew < ActiveRecord::Migration
  def self.up
# Note: This is so old the model classes no longer exist.
#    interpretations = Interpretation.find(:all)
#    interpretations.each { |interpretation|
#      cr = CachedResource.find_by_uri(interpretation.object_uri)
#      if cr
#        CollectedItem.create(:user_id => interpretation.user_id, :cached_resource_id => cr.id, :annotation => interpretation.annotation )
#      else
#        RAILS_DEFAULT_LOGGER.info("Interpretation (#{interpretation.id}) to CollectedItem: Can't find #{interpretation.object_uri} in CachedResource table.")
#      end
#    }
#
#    taggings = Tagging.find(:all)
#    taggings.each { |tagging|
#      interpretation = Interpretation.find_by_id(tagging.interpretation_id)
#      if interpretation
#        cr = CachedResource.find_by_uri(interpretation.object_uri)
#        if cr
#          ci = CollectedItem.find(:first, :conditions => [ "user_id = ? AND cached_resource_id = ?", interpretation.user_id, cr.id ])
#          if ci
#            Tagassign.create(:tag_id => tagging.tag_id, :collected_item_id => ci.id)
#          else
#            RAILS_DEFAULT_LOGGER.info("Tagging (#{tagging.id}) to Tagassign: Can't find user=#{interpretation.user_id}, cached resource=#{cr.id} in CollectedItem table.")
#          end
#        else
#            RAILS_DEFAULT_LOGGER.info("Tagging (#{tagging.id}) to Tagassign: Can't find #{interpretation.object_uri} in CachedResource table.")
#        end
#      else
#        RAILS_DEFAULT_LOGGER.info("Tagging (#{tagging.id}) to Tagassign: Can't find #{tagging.interpretation_id} in Interpretation table.")
#      end
#    }
  end

  def self.down
  end
end
