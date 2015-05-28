module Typewright::OverviewsHelper
   def tw_format_corrector(corrector)
      username = corrector['username']
      if username.nil? || username.blank?
         username = Typewright::User.get_author_fullname(corrector['federation'], corrector['id'])
      end
      link = link_to(username, "/typewright/overviews/#{corrector['id']}", { :class=> 'nav_link' })
      count = corrector['count'].present? ? " (#{corrector['count']})" : ""
      return content_tag(:div, raw("#{link}#{count}"), {})
   end

   def tw_format_doc_status( status )
      return 'No' if status == 'not_complete'
      return 'User marked complete' if status == 'user_complete'
      return 'Confirmed complete' if status == 'complete'
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
      link_to(truncate(document['title'], :length => 50), "/typewright/documents/0?uri=#{uri}", { :class=> 'nav_link', title: document['title'] })
   end

   def tw_document_retrieval_link(label, uri, type, mime)
      output_name = "#{uri.split("/").last}-#{type}"
      return link_to(label, "/typewright/overviews/retrieve_doc.#{mime}?uri=#{uri}&type=#{type}", { download: output_name, :class=>'tw-retrieve-link' } )
   end

   def tw_document_retrieval_links(document)
      uri = document['uri'].present? ? document['uri'] : document['id']
      html = content_tag(:div, { :class=> 'tw-document-retrieval'}) do
         tw_document_retrieval_link('Corrected eMOP XML', uri, 'alto', 'xml') +
         tw_document_retrieval_link('Corrected Text', uri, 'text', 'txt') +
         tw_document_retrieval_link('Corrected TEI-A', uri, 'tei-a', 'xml') +
         tw_document_retrieval_link('Corrected TEI-A (words)', uri, 'tei-a-words', 'xml') +
         tw_document_retrieval_link('Original XML', uri, 'original-xml', 'xml') +
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
