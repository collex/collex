module CommunitiesHelper
	def make_group_home_link(category)
		case category
		when "community" then return "/communities"
		when "peer-reviewed"  then return "/publications"
		when "classroom" then return "/classroom"
		end
	end

	def make_exhibit_home_link(exhibit)
		if exhibit.group_id == nil || exhibit.group_id.to_i <= 0
			return link_to("[Return to #{Setup.community_tab()}]", '/communities', { :class => 'nav_link' })
		end

		group = Group.find_by_id(exhibit.group_id)
		if group
			return link_to("[Return to Group]", "#{group.get_visible_url()}", { :class => 'nav_link' })
		else
			return link_to("[Return to #{Setup.community_tab()}]", '/communities', { :class => 'nav_link' })
		end
	end

	def singularize_and_downcase(word)
		return word.downcase.chomp('s')
	end

	def link_to_trashcan(alt, action, el, params, wait_message)
		raw(link_to_function image_tag('lvl2_trash.gif', { alt: alt }),
			"serverAction({action: { actions: '#{action}', els: '#{el}', params: '#{params}'}, progress: { waitMessage: '#{wait_message}' + '...' }})")
	end
end
