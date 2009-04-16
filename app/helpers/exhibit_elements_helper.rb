module ExhibitElementsHelper
  def get_exhibit_id(exhibit)
    return exhibit.visible_url && exhibit.visible_url.length > 0 ? exhibit.visible_url : exhibit.id
  end
  def get_exhibit_url(exhibit)
    return "/exhibits/#{get_exhibit_id(exhibit)}"
  end
  def get_exhibit_link(exhibit)
    return "<a class='nav_link' href='#{get_exhibit_url(exhibit)}'>#{h exhibit.title}</a>"
  end
  def get_exhibits_username(exhibit)
    user_id = exhibit.user_id
    user_id = exhibit.alias_id if exhibit.alias_id != nil
    return User.find(user_id).fullname
  end
   def get_exhibit_user_link(exhibit)
    user_id = exhibit.user_id
    user_id = exhibit.alias_id if exhibit.alias_id != nil
    owner = User.find(user_id)
    get_user_link(owner)
   end
end
