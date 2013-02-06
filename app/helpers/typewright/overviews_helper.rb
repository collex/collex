module Typewright::OverviewsHelper
	def tw_format_corrector(corrector)
		full_name = Typewright::User.get_author_fullname(corrector['federation'], corrector['id'])
		#user = Typewright::User.get_author_native_rec(corrector['federation'], corrector['id'])
		link = link_to(full_name, "/typewright/overviews/#{corrector['id']}", { class: 'nav_link' })

		count = corrector['count'].present? ? " (#{corrector['count']})" : ""
		return content_tag(:div, raw("#{link}#{count}"), {})
	end

	def tw_format_correctors(correctors)
		html = raw("")
		correctors.each { |corrector|
			html += tw_format_corrector(corrector)
		}
		return html
	end

	def tw_document_link(document)
		uri = document['uri'].present? ? document['uri'] : document['id']
		link_to(truncate(document['title'], :length => 50), "/typewright/documents/0?uri=#{uri}", { class: 'nav_link', title: document['title'] })
	end

	def tw_document_retrieval_link(label, uri, type, mime)
		output_name = "#{uri.split("/").last}-#{type}"
		return link_to(label, "/typewright/overviews/retrieve_doc.#{mime}?uri=#{uri}&type=#{type}", { download: output_name } )
	end

	def tw_document_retrieval_links(document)
		uri = document['uri'].present? ? document['uri'] : document['id']
		html = content_tag(:div, { class: 'tw-document-retrieval'}) do
			tw_document_retrieval_link('Corrected Gale XML', uri, 'gale', 'xml') +
				tw_document_retrieval_link('Corrected Text', uri, 'text', 'txt') +
				tw_document_retrieval_link('Corrected TEI-A', uri, 'tei-a', 'xml') +
				tw_document_retrieval_link('Original Gale XML', uri, 'original-gale', 'xml') +
				tw_document_retrieval_link('Original Text', uri, 'original-text', 'txt')
		end
	end

	def tw_format_documents(documents)
		html = raw("")
		documents.each { |document|
			html += content_tag(:div, raw("#{tw_document_link(document)} (#{document['count']})"), {})
		}
		return html
	end
end
