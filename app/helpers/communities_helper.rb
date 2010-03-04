module CommunitiesHelper
	def make_exhibit_home_link(category)
		case category
		when "community" then return "/communities"
		when "peer-reviewed"  then return "/publications"
		when "classroom" then return "/classroom"
		end
	end
end
