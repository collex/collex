class CollectedItem < ActiveRecord::Base
  has_many :tagassigns 
  has_many :tags, :through => :tagassigns 
  belongs_to :cached_resource
  belongs_to :user
  
  def self.get_all_users_collections(user)
    return find(:all, :conditions => [ "user_id = ?", user.id ])
  end

  def self.collect_item(user, uri)
    # This collects an item for a particular user. Different users can collect the same item, but a single
    # user can only collect an item once. If the items was collected successfully, then this returns the
    # item. If there is an error, then it throws an exception.
    
    # Has it been collected before?
    cached_resource = CachedResource.find(:first, :conditions => [ "uri = ?" , uri ])
    if (cached_resource != nil)
      item = find(:first, :conditions => [ "user_id = ? AND cached_resource_id = ?", user.id, cached_resource.id ])
      if item != nil
        err_str = "Can't collect item because it is already collected. User=#{user.username} Item=#{uri}"
        logger.info(err_str)
        return  # Just return with no effect if it is already collected. It doesn't matter.
      end
    end
    
    # Create cached_resource item if it hasn't been created
    if (cached_resource == nil)
      cached_resource = CachedResource.new(:uri => uri)
    end
    
    # Store the item
    item = CollectedItem.new
    item.user = user
    item.cached_resource = cached_resource
    item.save!
    
    return item
  end
  
  def self.get(user, uri)
    cached_resource = CachedResource.find(:first, :conditions => [ "uri = ?" , uri ])
    if (cached_resource == nil)
      return nil
    end
    
    user_id = user.id
    cached_resource_id = cached_resource.id
    item = find(:first, :conditions => [ "user_id = ? AND cached_resource_id = ?", user_id, cached_resource_id ])
    return item
  end
  
  def self.remove_collected_item(user, uri)
    # Right now we've decided to never remove an item from the cache, even if it is no longer referenced, so we just
    # need to delete the reference. This may change if the cache grows stupendously.
    item = self.get(user, uri)
    if item == nil
      logger.info("Can't remove the item: #{user.username}, #{uri} because it couldn't be found")
      return  # Just return with no effect if it is already collected. It doesn't matter.
    end
    
    # also remove any entries in the join table
    tagassigns = Tagassign.find(:all, :conditions => [ "collected_item_id = ?", item.id ])
    tagassigns.each { |tagassign|
      tag_str = tagassign.tag
      tagassign.destroy
      delete_tag_if_orphan(tag_str)
    }
    item.destroy()
  end
  
  def self.set_annotation(user, uri, note_str)
    username = user.username
    item = self.get(user, uri)
    if item == nil
      logger.info("Can't set the annotation because uri #{uri} is not collected by #{username}")
      return
    end
  
    item.update_attribute(:annotation, note_str)
  end
  
  def self.add_tag(user, uri, tag_str)
    # find the collected item record. It must exist.
    username = user.username
    item = self.get(user, uri)
    if item == nil
      logger.info("Can't set the tag because uri #{uri} is not collected by #{username}")
      return
    end
    
    # find or create the tag record.
    tag_str = tag_str.gsub(' ', '_')
    tag_rec = Tag.find_by_name(tag_str)
    if tag_rec == nil
      tag_rec = Tag.new(:name => tag_str)
      tag_rec.save!
    end

    # if the item was already tagged, then don't add a new entry for it. Instead we want to update the current entry.
    tagassign = Tagassign.find(:first, :conditions => [ "tag_id = ? AND collected_item_id = ?", tag_rec.id, item.id])
    if tagassign == nil
      tagassign = Tagassign.new(:tag_id => tag_rec.id, :collected_item_id => item.id)
      tagassign.save!
    else
      tagassign.update_attribute(:updated_at, Time.now)
    end
  end

  def self.delete_tag(user, uri, tag_str)
    # find the collected item record. It must exist.
    username = user.username
    item = self.get(user, uri)
    if item == nil
      logger.info("Can't delete the tag because uri #{uri} is not collected by #{username}")
      return
    end

    # find the tag record.
    tag_rec = Tag.find_by_name(tag_str)
    if tag_rec == nil # For some reason the tag was already deleted. Don't worry about it, it was probably a race condition or stale session.
      return
    end

    # if the item was not tagged, throw an exception. Otherwise, delete the pairing, and if the tag no longer
    # is referenced, delete the tag, too.
    tagassign = Tagassign.find(:first, :conditions => [ "tag_id = ? AND collected_item_id = ?", tag_rec.id, item.id])
    if tagassign == nil
      logger.info("Can't delete the tag because the tag #{tag_str} was not assigned to the uri #{uri} by user #{username}")
      return
    else
      tagassign.destroy
      delete_tag_if_orphan(tag_str)
    end
  end
  
  private
  def self.delete_tag_if_orphan(tag_str)
    tag_rec = Tag.find_by_name(tag_str)
    return if tag_rec == nil
    
    col = tag_rec.collected_items
    if col.length == 0
      tag_rec.destroy
    end
  end
end
