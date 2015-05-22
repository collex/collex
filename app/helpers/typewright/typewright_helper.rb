module Typewright::TypewrightHelper
	def tw_create_url(doc_id, page)
		return "/typewright/documents/#{doc_id}/edit?src=#{@src}&page=#{page}"
	end

	def tw_create_show_url(uri, src = @src)
    		src ||= :gale
		return "/typewright/documents/0?uri=#{uri}\&src=#{src}"
	end

	def tw_abbrev(str)
		return str.length > 32 ? str.slice(0..30)+'...' : str
	end

	def tw_date_format(date)
		return date.iso8601
	end

   def tw_source(curr_src)
      html = "OCR Source: "
      curr_src = "eMOP" if curr_src.to_s.downcase == "alto"
      html += "<span class=\"tw_selected_source\">#{curr_src}</span> "
      return html
   end

	def draw_revision_pager( uri, curr_page, total_pages )
	  html = ""

    # If there's only one page, don't show any pagination
    if total_pages == 1
      return ""
    end
    
    # Show only a maximum of 11 items, with the current item centered if possible.
    # First figure out the start and end points we want to display.
    if total_pages < 11
      first = 1
      last = total_pages
    else
      first = curr_page - 5
      last = curr_page + 5
      if first < 1
        first = 1
        last = first + 10
      end
      if last > total_pages
        last = total_pages
      end
    end

    # core components of the pagining links
    link = "/typewright/documents/0?uri=#{uri}&revision_page="
    spacing = "&nbsp;&nbsp;"
    
    # if the first page in the range of pages displayed
    # is not 1, we must show a 'first' link to go directly
    # to page 1
    if first > 1
      page = "1"
      html += link_to("first", link+page, :class => "tw_revison_paging_link")
      html += spacing
      
      # additionally, show a skip in the pages with '...'
      # and a way to skp bat by one page ( '<<')
      page = "#{(curr_page - 1)}"
      html += link_to("<<", link+page, :class => "tw_revison_paging_link")
      html += spacing
      html += "..." + spacing
    end

    # draw a linked page number for each page in the 
    # 11 visible pages. Don't link the current page
    for pg in first..last do
      if pg == curr_page
        html += "<span class='tw_curr_revision_page'>#{pg}</span>"
      else
        page = "#{pg}"
        html += link_to(page, link+page, :class => "tw_revison_paging_link")
      end
      html += spacing
    end 
    
    # If last visible page is < total pages, show a skipped pages
    # marker (...), followed by a page forward marker (>>>),
    # followed by a direct link to the last page
    if last < total_pages
      html += "...&nbsp;&nbsp;" if total_pages > 12
      page = "#{(curr_page + 1)}"
      html += link_to(">>", link+page, :class => "tw_revison_paging_link")
      html += spacing
      page = "#{total_pages}"
      html += link_to("last", link+page, :class => "tw_revison_paging_link")
    end
    
    


    return raw(html)
  
	end

	def tw_percent_edited_display(stats)
		return 0 if stats[:pages_with_changes] == 0 || stats[:num_pages] == 0
		percent = stats[:pages_with_changes] * 100 / stats[:num_pages]
		return "<1" if percent < 1
		return percent.to_s
	end
end
