# ------------------------------------------------------------------------
#     Copyright 2011 Applied Research in Patacriticism and the University of Virginia
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
# ----------------------------------------------------------------------------

class Typewright::Line < ActiveResource::Base
	if COLLEX_PLUGINS['typewright']
		self.site = COLLEX_PLUGINS['typewright']['web_service_url']
	end

	#def self.find_all_by_document_id_and_page_and_src(document_id, page, src)
	#	self.find(:all, :params => { :document_id => document_id, :page => page, :src => src })
	#end

	def self.find_all_by_document_id_and_page_and_line_and_src(document_id, page, line, src)
		self.find(:all, :params => { :document_id => document_id, :page => page, :line => line, :src => src })
	end

	def self.revisions(uri, start, size, src)
		self.find(:all, :params => { :uri => uri, :src => src, :revisions => true, :start => start, :size => size})
	end

  def self.words_to_db(words)
  	return nil if words == nil
  	w = ""
  	words.each {|word|
  		w += "#{word[:l]}\t#{word[:t]}\t#{word[:r]}\t#{word[:b]}\t#{word[:line]}\t#{word[:word]}\n"
  	}
  	return w
  end

	def self.db_to_words(db)
		w = []
		words = db ? db.split("\n") : []
		words.each {|word|
			items = word.split("\t")
			w.push({ :l => items[0], :t => items[1], :r => items[2], :b => items[3], :line => items[4], :word => items[5] })
		}
		return w
	end

	def self.words_to_text(words)
		str = ""
		words.each {|word|
			str += ' ' if str != ''
			str += word[:word]
		}
		return str
	end

	def self.get_undoable_record(book, page, line, user, src)
    begin
      corrections = self.find_all_by_document_id_and_page_and_line_and_src(book, page, line, src)
      return nil if corrections.length == 0
      return nil if corrections.last.federation != user.federation || corrections.last.orig_id != user.orig_id
      return corrections.last
    rescue
      # TODO: Log error here
      return nil
    end
	end


end

