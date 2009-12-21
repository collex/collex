##########################################################################
# Copyright 2007 Applied Research in Patacriticism and the University of Virginia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################

require 'rubygems'
require 'solr'
require 'cgi'
require 'script/lib/nines_mapping.rb'
require 'script/lib/title_code_exceptions.rb'

require 'script/lib/marc_ext/lib/marc_ext.rb'
require 'marc_ext/record'
class MARC::Record
  include MARCEXT::Record
end

# Monkey patch so that it can take a record count
class Solr::Indexer
	def set_max(max)
		@max_records = max
	end
  def index()
    buffer = []
		count = 0
    @data_source.each do |record|
			count += 1
			if @max_records == nil || count <= @max_records
				document = @mapper.map(record)

				# TODO: check arrity of block, if 3, pass counter as 3rd argument
				yield(record, document) if block_given? # TODO check return of block, if not true then don't index, or perhaps if document.empty?

				buffer << document

				if !@buffer_docs || buffer.size == @buffer_docs
					add_docs(buffer)
					buffer.clear
				end
			else
				break
			end
    end
    add_docs(buffer) if !buffer.empty?

    @solr.commit unless @debug
  end
end


# # IS THIS ACTUALLY USED ANYWHERE???
$KCODE = 'UTF8'

class MarcIndexer 
  
  include NinesMapping
  include TitleCodeExceptions
  
  URL_FORMULAE = {
    'bancroft' => ["http://oskicat.berkeley.edu/search~S1/?searchtype=c&searcharg=",
                  ['950','a'],['950','b'],
                  "&searchscope=1" ],
#    'bancroft' => ["http://pathfinder.berkeley.edu/WebZ/Authorize?sessionid=0:bad=html/authofail.html:next=NEXTCMD%22/WebZ/CheckIndexCombined:next=html/results.html:format=B:numrecs=20:entitytoprecno=1:entitycurrecno=1:tempjds=TRUE:entitycounter=1:entitydbgroup=Glad:entityCurrentPage=SearchRecentAcq:dbname=Glad:entitycountAvail=0:entitycountDisplay=0:entitycountWhere=0:entityCurrentSearchScreen=html/search.html:entityactive=1:indexA=cl%3D:termA=",
#                  ['950','a'],['950','b'],
#                  ":next=html/Cannedresultsframe.html:bad=error/badsearchframe.html" ],
    'lilly' => [ "http://www.iucat.iu.edu/uhtbin/cgisirsi/x/0/0/5?library=ALL&searchdata1=^C", ['001'] ],
    'uva_library' => [ "http://virgo.lib.virginia.edu/uhtbin/cgisirsi/uva/0/0/5?searchdata1=", :parse_uva_id, "{CKEY}"  ],
		'estc' => [ "http:/estc.com?search="]
  }

	NEEDS_FEDERATION = {
		'bancroft' => true,
		'lilly' => true,
		'estc' => false
	}
  
  def self.run( args )
    
    unless URL_FORMULAE.keys.include?(args[:archive])  
      puts "WARNING: Unable to form URLs for unknown archive: #{args[:archive]}"
    end
    
    if args[:archive].nil?
      puts "ERROR: No archive code specified, use -a option to specify an archive."
      return
    end

		if args[:federation].nil? && NEEDS_FEDERATION[args[:archive]]
      puts "ERROR: No federation specified, use -f option to specify a federation."
      return
		end
    
    puts "Indexing MARC data..."
    start_time = Time.new ## start the clock
    
    marc_indexer = MarcIndexer.new(args) 
    marc_indexer.index_directory(args[:dir], args[:archive], args[:federation])
   
    end_time = Time.new
    time_lapsed = end_time - start_time
    puts "Indexing completed in #{time_lapsed} seconds" 
  end
  
  def initialize( args )
    @url_log_path = args[:url_log_path]
    @verbose = args[:verbose]
    @forgiving_marc_decoding = args[:forgiving]
    @indexer_config = {:debug => args[:debug], :timeout => 1200, :solr_url => args[:solr_url], :buffer_docs => 500 }     
    @archive_id = args[:archive]
		@max_records = args[:max_records].to_i
    
    unless args[:target_uri_file].nil?
      # load a ruby file which defines the @target_uris hash
      require args[:target_uri_file]
    else
      @@target_uris = nil
    end
  end
  
  def index_directory( dir, archive_id, federation )
    @archive_id = archive_id
		@federation = federation
    @batch_id = "MARC-#{Time.now.xmlschema.gsub(/\:/,'-')}"
    @total_record_count = 0
    
    @url_log = File.open(@url_log_path, 'w')
    
    ## put all of the .mrc files in the directory into an array
    marc_files = Dir["#{dir}/*.mrc"].entries
        
    ## index each file
    marc_files.each do |marc_file|
      index_file(marc_file)
      @total_record_count = @total_record_count + @file_record_count
    end
    
    if not @indexer_config[:debug]
      solr = Solr::Connection.new( @indexer_config[:solr_url], @indexer_config )

      puts "Deleting previous batches..."
      solr.delete_by_query "+archive:#{@archive_id} -batch:#{@batch_id}"
      puts "Optimizing the index..."
      solr.optimize
      puts "Refreshing Solr caches..."
      system("curl #{@indexer_config[:solr_url]}/select?qt=cache_refresh")
    end
    
    @url_log.close
    
    puts "Indexed #{@total_record_count} MARC records"
  end
  
  def index_file( marc_file )
    puts "Indexing #{marc_file}"
    marc_data_source = MARC::ForgivingReader.new(marc_file) #, {:forgiving => @forgiving_marc_decoding})
    reset_progress_meter
    indexer = Solr::Indexer.new(marc_data_source, mapping, @indexer_config)
		indexer.set_max(@max_records) if @max_records
		this_doc = nil
		begin
			indexer.index do |marc_record, solr_document|
				this_doc = solr_document
				# only index objects on the whitelist if there is one
				unless @@target_uris.nil?
					id = marc_record.extract('001').first.to_sym
					unless @@target_uris[id]
						# report_record_skipped( marc_record ) if @verbose
						next false
					end
				end

				log_url( solr_document[:uri], marc_file, solr_document[:url] )
				if @verbose
					report_record( marc_record, solr_document )
					update_progress_meter if @max_records
				else
					update_progress_meter
#					if solr_document[:title].length != 0 || solr_document[:date_label].length != 0 || solr_document[:agent].length != 0 || solr_document[:role_PBL].length != 0 || solr_document[:year].length != 0 || solr_document[:text].length != 0 || solr_document[:role_AUT].length != 0
#						if solr_document[:title].length == 0
#							puts "~~~~~~~~~~~~~~~~ NO TITLE ~~~~~~~~~~~~~~~~~"
#							report_record( marc_record, solr_document )
#						end
#						if solr_document[:role_AUT].length == 0
#							puts "~~~~~~~~~~~~~~~~ NO AUTHOR ~~~~~~~~~~~~~~~~~"
#							report_record( marc_record, solr_document )
#						end
#					end
				end

#				if  @max_records && @file_record_count >= @max_records
#					puts "#\n# Stopped indexing by request after #{@file_record_count} records\n#"
#					return
#				end
				# this record should be indexed
				next true
			end
		rescue Exception => e
			puts "Error indexing: #{this_doc[:uri]}"
			puts e
		end
    puts "Indexed #{@file_record_count} MARC records"
  end  
  
  def report_record_skipped( marc_record )
    puts "Record Skipped: #{parse_uri(marc_record)}"
  end
      
  def report_record( marc_record, solr_document )
    puts "Marc Record"
    puts "==========="
    puts marc_record.to_s
    puts
    puts "Solr Document"
    puts "============="
    solr_document.keys.each do |field|
      puts "#{field}: #{solr_document[field]}"
    end
    puts 
  end
  
  def reset_progress_meter
    @file_record_count = 0
  end

  def update_progress_meter
    @file_record_count = @file_record_count + 1
    if @file_record_count % 100 == 0
      print "."
      STDOUT.flush
    end
  end
  
  def log_url( uri, file, url )
    @url_log.puts("#{uri}\t#{file}\t#{url}\n")
  end
  
  def get_proc( method_sym )
    self.method( method_sym ).to_proc
  end
  
  def mapping
    { 
      :uri => get_proc( :parse_uri ),
      :url => get_proc( :parse_url ),
      :title => get_proc( :parse_title ),
      :genre => get_proc( :parse_genre ),
      :date_label => get_proc( :parse_year ),
      :year => get_proc( :parse_year ),
      :text => get_proc( :parse_text ),
      :role_PBL => get_proc( :parse_publisher ),
      :role_AUT => get_proc( :parse_author ), 
      :agent => get_proc( :parse_author ), 
      :archive => @archive_id,
      :federation => get_proc( :parse_federation ),
			:has_full_text => "F",
			:is_ocr => get_proc( :parse_is_ocr ),
      :title_sort => get_proc( :parse_title ),
      :author_sort => get_proc( :parse_author_sort ),
      :year_sort => get_proc( :parse_year_sort ),
  #    :type => "A",  # a NINES "archive" object, as opposed to a "collectable" (type "C")
      :batch => @batch_id

  # These fields are not populated currently
  #    :free_culture => 
  #    :alternative => 
  #    :date => 
  #    :source => 
  #    :thumbnail => 
  #    :image =>
	#    :role_ART =>
    }
  end
  
  def extract_record_data(record, field)
    extracted_data = []

    tag = field.to_s[0,3]

    extracted_fields = record.find_all {|f| f.tag === tag}

    extracted_fields.each do |field_instance|    
      if tag < '010' # control field
        extracted_data << field_instance.value.sub(/\.$/,'') rescue nil
      else # data field
        subfield = field.to_s[3].chr
        field_instance.find_all {|x| x.code === subfield }.each do |sf|
          extracted_data << sf.value.sub(/\.$/,'') rescue nil
        end
      end
    end

    extracted_data.compact.uniq
  end

	def parse_federation( record )
		return @federation if @federation != nil
		years = parse_year( record )
		nines = false
		eighteen = false
		years.each { |year|
			y = year.to_i
			eighteen = true if y > 1680 && y < 1820
			nines = true if y > 1780 && y < 1920
		}
		if nines && eighteen
			return "NINES;18th Connect"
		elsif nines && !eighteen
			return "NINES"
		elsif !nines && eighteen
			return "18th Connect"
		end
		return nil
	end

  def parse_uri( record )
    id = record.extract('001')
    "lib://#{@archive_id}/#{id}"
  end

	def test_for_problem_record(record)
#		id = record.extract('001')
#		if id.to_s == "1373"
#			puts "problem doc"
#		end
	end
  
  def parse_title( record )
    test_for_problem_record(record)

    # bancroft stores titles in wierd places sometimes
    if @archive_id == 'bancroft'
      id = record.extract('001')
      title_location = TITLE_CODE_EXCEPTIONS[id.to_s]
      title = record.extract(title_location).to_s if title_location
      subtitle = ''
    end
    
    unless title 
      title = record.extract('245a').to_s.strip
			if title.length == 0
	      rec = record.extract('260a')
				if rec != nil
					title = rec.to_s.strip
				end
			end
      subtitle = record.extract('245b').to_s.strip
    end
    
    fulltitle = ''
    if subtitle.length > 0 ## if we have a subtitle, append it to the title nicely 
      #if(fulltitle =~ /[:/,]$/  )
      fulltitle = title + " " + subtitle.chomp('/')
    else
      fulltitle = title.strip.chomp("/")
    end
    fulltitle.sub(/[,;:]$/,"")
  end 
  
  def normalize_genre_field_value( value )
    return nil if value.nil?
    normal = value.downcase
    if normal[normal.size-1] == 46 # .
      normal = normal[0..-2]
    end
    normal
  end
  
  def genre_mapper(field)
    genres = []
    
    [ GENRE_MAPPING, GEOGRAPHIC_MAPPING, FORMAT_MAPPING ].each do |mapping|     
      mapping.keys.each do |key|
        matching_values = mapping[key]
        genre = normalize_genre_field_value(field)
        if !genre.nil? and matching_values.include? genre
          genres << key unless genres.include? key
        end
      end
    end
    
    genres
  end
  
  def get_subfield( record, code )
    field = record[code[0]]
    if field
      subfield = field[code[1]]
      if subfield
        return subfield
      end
    end
    return nil
  end

  def parse_genre( record )
    test_for_problem_record(record)
    nines_genres = ['Citation']
    SCAN_LIST.each do |genre_field|
      subfield = get_subfield( record, genre_field )
      genres = genre_mapper( subfield )
      genres.each do |genre|
        nines_genres << genre unless nines_genres.include?(genre)      
      end
    end
    nines_genres
  end
  
  def parse_year( record )
    test_for_problem_record(record)
     record.extract('260c').collect {|f| f.scan(/\d\d\d\d/)}.flatten
  end  
      
  def parse_year_sort( record )
		years = parse_year( record )
		if years.length > 1
			years = [ years[0] ]
		end
		return years
  end

  def parse_publisher( record )
    test_for_problem_record(record)
     # 260$b is publisher
     publishers = extract_record_data(record, '260b')
     publishers.map { |publisher| publisher.sub(/[,;:]$/,"") }
  end
  
  def parse_text( record )
    test_for_problem_record(record)
    s = ""

    # go through all the genre related fields and index that text for searching
    SCAN_LIST.each do |code|
      subfield = get_subfield( record, code )
      s << ' ' << subfield if subfield 
    end

		# Return nil if there isn't full text.
		s = s.strip()
    return s.length > 0 ? s : nil
  end
  
  def parse_is_ocr( record )
    test_for_problem_record(record)
		s = parse_text( record )

    return s != nil ? "F" : nil
  end

  def parse_author( record )
    test_for_problem_record(record)
    authors = AUTHOR_MARC_CODES.map { |code|
      get_subfield( record, code )
    }.compact
    authors.map { |author| author.sub(/[,;:]$/,"") }
  end
  
  def parse_author_sort( record )
		authors = parse_author( record )
		if authors.length > 1
			authors = [ authors[0] ]
		end
  end

  def parse_uva_id( record )
    test_for_problem_record(record)
    record.extract('001')[0].sub(/[u]/,"")
  end
  
  def parse_url( record )    
    test_for_problem_record(record)
    url_formula = URL_FORMULAE[@archive_id]
    return "" if url_formula.nil?

    url = ""    
    url_formula.each do |formula_element|
      case formula_element
        when Symbol
          url << get_proc( formula_element ).call(record)
        when String
          url << formula_element
        when Array
          if formula_element.length == 1 
            value = record.extract( formula_element[0] )
            value = value.to_s if value
          else
            value = get_subfield( record, formula_element )  
          end  
          unless value.nil?
            url << CGI.escape(value)
          end
      end
    end
    url
  end
  
end