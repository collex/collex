# encoding: UTF-8
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

class Typewright::XmlReader
require 'nokogiri'

	def self.format_page(page)
		page = "#{page}"
		while page.length < 4
		  page = '0' + page
		end
		return page
	end

	def self.read_gale(book, page)
		fname = "#{COLLEX_PLUGINS['typewright']['xml_path']}/#{book}/#{book}.xml"
		number = "#{book}#{self.format_page(page)}0"

		slash = fname.rindex('/')
		cache_name = fname[0..slash] + number
		ret = self.read_cache(cache_name, "gale")
		return ret if ret != nil

		doc = Nokogiri::XML(File.new(fname))
		#doc = REXML::Document.new( File.new(fname) )

		doc.xpath('//imageLink').each { |image|
		#REXML::XPath.each( doc, "//imageLink" ){ |image|
			arr = image.text.split('.')
			if number == arr[0]
				ret = self.read_gale_page(image, cache_name)
				return ret
			end
		}
		return nil
	end

	def self.read_gale_page(image, cache_name)
		page = image.parent.parent
		#content = page.elements['pageContent']
		ret = []
		lines = 0
		page.xpath('pageContent/p').each { |ps|
		#content.elements.each('p') { |ps|
			ps.xpath('wd').each { |wd|
			#ps.elements.each('wd') { |wd|
				pos = wd.attribute('pos')
				#pos = wd.attributes['pos']
				arr = pos.to_s.split(',')

				ret.push({ :l => arr[0].to_i, :t => arr[1].to_i, :r => arr[2].to_i, :b => arr[3].to_i, :word => wd.text, :line => lines })
			}
			lines += 1
		}
		self.write_cache(cache_name, "gale", ret)
		return ret
	end

	def self.read_all_gale(fname)
		doc = Nokogiri::XML(File.new(fname))
		#doc = REXML::Document.new( File.new(fname) )

		doc.xpath('//imageLink').each { |image|
		#REXML::XPath.each( doc, "//imageLink" ){ |image|
			print '.'
			arr = image.text.split('.')
			number = arr[0]
			slash = fname.rindex('/')
			cache_name = fname[0..slash] + number
			ret = self.read_gale_page(image, cache_name)
			self.write_cache(cache_name, "gale", ret)
		}
	end

	def self.create_metadata(fname)
		doc = Nokogiri::XML(File.new(fname))
		doc.xpath('//fullTitle').each { |node|
			title = { :title => node.text }
			arr = fname.split('.')
			fname = "#{arr[0]}_meta.yml"
			puts title[:title]
			File.open( fname, 'w' ) do |out|
				YAML.dump( title, out )
			end
		}
	end

	def self.read_metadata(book)
		fname = "#{COLLEX_PLUGINS['typewright']['xml_path']}/#{book}/#{book}_meta.yml"
		if File.exists?(fname)
			meta = YAML.load_file(fname)
			return meta[:title]
		end
		return ''
	end

	def self.read_gamera(book, page)
		fname = "#{COLLEX_PLUGINS['typewright']['xml_path']}/gamera-xml/#{book}/#{book}#{self.format_page(page)}0.xml"
		ret = self.read_cache(fname, "gamera")
		return ret if ret != nil

		begin
			doc = Nokogiri::XML(File.new(fname))
			#doc = REXML::Document.new( File.new(fname) )
		rescue
			self.write_cache(fname, "gamera", [])
			return []
		end

		doc.xpath('//page').each { |pg|
		#REXML::XPath.each( doc, "//page" ){ |page|
			ret = []
			lines = 0
			pg.xpath('line').each { |ln|
				ln.xpath('wd').each { |wd|
					pos = wd.attributes['pos']
					arr = pos.to_s.split(',')

					ret.push({ :l => arr[0].to_i, :t => arr[1].to_i, :r => arr[2].to_i, :b => arr[3].to_i, :word => wd.text, :line => lines })
				}
				lines += 1
			}
			self.write_cache(fname, "gamera", ret)
			return ret
		}
		return nil
	end

	def self.line_factory(l, t, r, b, line, words, text, num)
		return { :l => l, :t => t, :r => r, :b => b, :words => words, :text => text, :line => line, :num => num }
	end

	def self.create_lines(gamera_arr)
		ret = []
		gamera_arr.each_with_index { |wd, i|
			if !ret[wd[:line]]
				ret[wd[:line]] = { :l => wd[:l], :t => wd[:t], :r => wd[:r], :b => wd[:b], :words => [[wd]], :text => [wd[:word]], :line => wd[:line] }
			else
				line = ret[wd[:line]]
				line[:words][0].push(wd)
				begin
				line[:text][0] += ' ' +wd[:word]
				rescue
					puts "Failed on entry:#{i}"
				end
				line[:l] = wd[:l] if line[:l] > wd[:l]
				line[:t] = wd[:t] if line[:t] > wd[:t]
				line[:r] = wd[:r] if line[:r] < wd[:r]
				line[:b] = wd[:b] if line[:b] < wd[:b]
				line[:line] = wd[:line]
			end
		}
		return ret
	end

	def self.read_cache(xml_fname, prefix)
		arr = xml_fname.split('.')
		fname = "#{arr[0]}_#{prefix}.yml"
		if File.exists?(fname)
			words = YAML.load_file(fname)
			words.collect! {|word| { :l => word[:x], :t => word[:y], :r => word[:w], :b => word[:h], :word => word[:word] } }
			return words
		end
		return nil
	end

	def self.write_cache(xml_fname, prefix, words)
		arr = xml_fname.split('.')
		fname = "#{arr[0]}_#{prefix}.yml"
		File.open( fname, 'w' ) do |out|
			YAML.dump( words, out )
		end
	end

	def self.gale_create_lines(gale_arr)
		ret = []
		# this is an array of the paragraphs. We never want to join words across paragraphs, but we also want
		# to split the paragraphs into lines by starting a new line whenever the word doesn't overlap the last one.
		last_y = -1
		last_h = -1
		last_x = 200000
		last_line = -1
		line_num = -1
		gale_arr.each { |wd|
			if last_y > wd[:b] || last_h < wd[:t] || last_x > wd[:l] || last_line != wd[:line]
				line_num += 1
			end
			ret.push({ :l => wd[:l], :t => wd[:t], :r => wd[:r], :b => wd[:b], :word => wd[:word], :line => line_num })
			last_y = wd[:t]
			last_h = wd[:b]
			last_x = wd[:l]
			last_line = wd[:line]
		}
		return ret
	end
end
