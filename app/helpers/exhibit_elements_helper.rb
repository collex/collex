module ExhibitElementsHelper
  def get_exhibit_url(exhibit)
    return "/exhibits/#{exhibit.visible_url && exhibit.visible_url.length > 0 ? exhibit.visible_url : exhibit.id}"
  end
  def get_exhibit_link(exhibit)
    return "<a class='nav_link' href='#{get_exhibit_url(exhibit)}'>#{h exhibit.title}</a>"
  end
end
