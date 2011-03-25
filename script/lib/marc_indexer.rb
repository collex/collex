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

$KCODE = 'UTF8'

require "#{Rails.root}/script/lib/nines_mapping.rb"
require "#{Rails.root}/script/lib/title_code_exceptions.rb"

require "#{Rails.root}/script/lib/marc_ext/lib/marc_ext.rb"
require "#{Rails.root}/script/lib/marc_ext/lib/marc_ext/record.rb"
class MARC::Record
  include MARCEXT::Record
end

# this is based on the indexer in solr-ruby, which is the old gem that was used to wrap solr calls.
class SolrIndexer
  attr_reader :solr

  # TODO: document options!
  def initialize(archive, data_source, mapper_or_mapping, options={})
	  @rdf_path = options[:rdf_path]
	  if @rdf_path == nil
	    @solr = CollexEngine.new(["archive_" + archive])	# = Solr::Connection.new(solr_url, options) #TODO - these options contain the solr_url and debug keys also, so tidy up what gets passed
	  else
		  @archive = archive
	  end

    @data_source = data_source
    @mapper = mapper_or_mapping.is_a?(Hash) ? SolrImporterMapper.new(mapper_or_mapping) : mapper_or_mapping

    @buffer_docs = options[:buffer_docs]
    @debug = options[:debug]
	  @prefix = options[:prefix]
  end

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
			  add = true
			  add = yield(record, document) if block_given?

			  buffer << document if add

			  if !@buffer_docs || buffer.size == @buffer_docs
				  add_docs(buffer)
				  buffer.clear
			  end
		  else
			  break
		  end
  end
  add_docs(buffer) if !buffer.empty?
end

  def add_docs(documents)
	  if @rdf_path == nil
    @solr.add_object(documents) unless @debug
	  else
		  documents.sort! { |a,b| a[:uri] <=> b[:uri] }
		  path = "#{@rdf_path}/#{@archive}"
		  path += "/#{@prefix}" if @prefix
		  RegenerateRdf.regenerate_all(documents, path, @archive)
	  end

    puts documents.inspect if @debug
  end
end

class SolrImporterMapper
  def initialize(mapping, options={})
    @mapping = mapping
    @options = options
  end

  def field_data(orig_data, field_name)
    orig_data[field_name]
  end

  def mapped_field_value(orig_data, field_mapping)
    case field_mapping
      when String
        field_mapping
      when Proc
        field_mapping.call(orig_data)  # TODO pass in more context, like self or a function for field_data, etc
      when Symbol
        field_data(orig_data, @options[:stringify_symbols] ? field_mapping.to_s : field_mapping)
      when Enumerable
        field_mapping.collect {|orig_field_name| mapped_field_value(orig_data, orig_field_name)}.flatten
      else
        raise "Unknown mapping for #{field_mapping}"
    end
  end

  def map(orig_data)
    mapped_data = {}
    @mapping.each do |solr_name, field_mapping|
      value = mapped_field_value(orig_data, field_mapping)
      mapped_data[solr_name] = value if value
    end

    mapped_data
  end
end

# Monkey patch forgiving reader to put in logging
require 'iconv'
module MARC
	class Reader
		# This is monkey patched to handle the marc-8 character set
		def self.decode(marc, params={})
			marc.force_encoding("ASCII-8BIT")
		  record = Record.new()
		  record.leader = marc[0..LEADER_LENGTH-1]

		  # where the field data starts
		  base_address = record.leader[12..16].to_i

		  # get the byte offsets from the record directory
		  directory = marc[LEADER_LENGTH..base_address-1]

		  throw "invalid directory in record" if directory == nil

		  # the number of fields in the record corresponds to
		  # how many directory entries there are
		  num_fields = directory.length / DIRECTORY_ENTRY_LENGTH

		  # when operating in forgiving mode we just split on end of
		  # field instead of using calculated byte offsets from the
		  # directory

		  # TODO-PER: change this data to utf-8 if necessary
		  field_area = marc[base_address..-1]
		  all_fields = field_area.split(END_OF_FIELD)

		  0.upto(num_fields-1) do |field_num|

			# pull the directory entry for a field out
			entry_start = field_num * DIRECTORY_ENTRY_LENGTH
			entry_end = entry_start + DIRECTORY_ENTRY_LENGTH
			entry = directory[entry_start..entry_end]

			# extract the tag
			tag = entry[0..2]

			# get the actual field data
			# if we were told to be forgiving we just use the
			# next available chuck of field data that we
			# split apart based on the END_OF_FIELD
			field_data = ''
			if params[:forgiving]
			  field_data = all_fields.shift()

			# otherwise we actually use the byte offsets in
			# directory to figure out what field data to extract
			else
			  length = entry[3..6].to_i
			  offset = entry[7..11].to_i
			  field_start = base_address + offset
			  field_end = field_start + length - 1
			  field_data = marc[field_start..field_end]
			end

			# remove end of field -- also fix encoding if necessary
			begin
				field_data.force_encoding("UTF-8")
				field_data.delete!(END_OF_FIELD)
			rescue
				  ic = Iconv.new('UTF-8','CP1252')
				  conv = ic.iconv(field_data)
				  # TODO-PER: This isn't correct so just remove all multi-byte chars
				  field_data = ''
				  conv.each_char { |ch|
					  field_data += ch if ch.bytesize == 1
				  }
				  field_data.delete!(END_OF_FIELD)
			end

			# add a control field or data field
			if MARC::ControlField.control_tag?(tag)
			  record.append(MARC::ControlField.new(tag,field_data))
			else
			  field = MARC::DataField.new(tag)

			  # get all subfields
			  subfields = field_data.split(SUBFIELD_INDICATOR)

			  # must have at least 2 elements (indicators, and 1 subfield)
			  # TODO some sort of logging?
			  next if subfields.length() < 2

			  # get indicators
			  indicators = subfields.shift()
			  field.indicator1 = indicators[0,1]
			  field.indicator2 = indicators[1,1]

			  # add each subfield to the field
			  subfields.each() do |data|
				subfield = MARC::Subfield.new(data[0,1],data[1..-1])
				field.append(subfield)
			  end

			  # add the field to the record
			  record.append(field)
			end
		  end

		  return record
		end
	end

	class ForgivingReader
		def set_logger(logger)
			@@logger = logger
		end
	  def each
		@handle.each_line(END_OF_RECORD) do |raw|
			record = MARC::Reader.decode(raw, { :forgiving => true, :logger => @@logger })
			yield record
		end
	  end
	end
end

class MarcIndexer
  
  include NinesMapping
  include TitleCodeExceptions
  
  URL_FORMULAE = {
    'bancroft' => ["http://oskicat.berkeley.edu/search~S1/?searchtype=c&searcharg=",
                  ['950','a'],['950','b'],
                  "&searchscope=1" ],
    'lilly' => [ "http://www.iucat.iu.edu/uhtbin/cgisirsi/x/0/0/5?library=ALL&searchdata1=^C", ['001'] ],
    'uva_library' => [ "http://virgo.lib.virginia.edu/uhtbin/cgisirsi/uva/0/0/5?searchdata1=", :parse_uva_id, "{CKEY}"  ],
		'estc' => [ "http://estc.bl.uk/", :parse_estc_record ],
		'galeDLB' => [ "http://galeDLB", ['001'] ],
		'flBaldwin' => [ "http://flBaldwin", ['001'] ]
  }

	NEEDS_FEDERATION = {
		'bancroft' => true,
		'lilly' => true,
		'estc' => false,
		'galeDLB' => true,
		'flBaldwin' => true
	}

	URI_FIELD = {
		'bancroft' => [  "lib://bancroft/", [ '001'] ],
		'lilly' => [  "lib://lilly/", [ '001'] ],
		'estc' => [  "lib://estc/", :parse_estc_record ],
		'galeDLB' => [ 'lib://galeDLB/', ['001']],
		'flBaldwin' => [ 'lib://flBaldwin/', ['001']]
	}
  
	def self.run( args )
		marc_indexer = MarcIndexer.new(args)

		unless URL_FORMULAE.keys.include?(args[:archive])
			marc_indexer.log_error("WARNING: Unable to form URLs for unknown archive: #{args[:archive]}")
		end

		if args[:archive].nil?
			marc_indexer.log_error("ERROR: No archive code specified, use -a option to specify an archive.")
			marc_indexer.close_logs()
			return
		end

		if args[:federation].nil? && NEEDS_FEDERATION[args[:archive]]
			marc_indexer.log_error("ERROR: No federation specified, use -f option to specify a federation.")
			marc_indexer.close_logs()
			return
		end

#		require 'ruby-prof'

		marc_indexer.index_directory(args[:dir], args[:archive], args[:federation])

#		result = RubyProf.stop
#		printer = RubyProf::FlatPrinter.new(result)
#		printer.print(STDOUT, 0)

		marc_indexer.close_logs()
	end

  def close_logs()
	  @url_log.close
	  @progress_log.close
	  @error_log.close
  end

  def log_error(str)
	  @error_log.puts("#{Time.now}: #{str}")
  end

  def log_progress(str)
	  @progress_log.puts("#{Time.now}: #{str}")
	  @progress_log.flush()
  end

  def initialize( args )
	  url_log_path = args[:url_log_path]
	  progress_log_path = args[:progress_log_file]
	  error_log_path = args[:error_log_file]
	  @url_log = File.open(url_log_path, 'w')
	  @progress_log = File.open(progress_log_path, 'w')
	  @error_log = File.open(error_log_path, 'w')
	  @rdf_path = args[:rdf_path]

    @verbose = args[:verbose]
    @dates_only = args[:dates_only]
    @forgiving_marc_decoding = args[:forgiving]
	  buffer_size = @rdf_path == nil ? 500 : -1
    @indexer_config = {:debug => args[:debug], :timeout => 1200, :solr_url => args[:solr_url], :buffer_docs => buffer_size, :rdf_path => @rdf_path }
    @archive_id = args[:archive]
		@max_records = args[:max_records] ? args[:max_records].to_i : nil
    
    unless args[:target_uri_file].nil?
      # load a ruby file which defines the @target_uris hash
      require args[:target_uri_file]
    else
      @@target_uris = nil
    end
  end
  
  def index_directory( dir, archive_id, federation )
	  log_progress("Indexing MARC data...")
	  start_time = Time.new ## start the clock

    @archive_id = archive_id
		@federation = federation
    @batch_id = "MARC-#{Time.now.xmlschema.gsub(/\:/,'-')}"
    @total_record_count = 0

	if !@rdf_path
		@solr = CollexEngine.new(["archive_" + @archive_id])
		begin
			@solr.start_reindex() if !@indexer_config[:debug]
		rescue Exception => e
			log_error("Error opening marc archive: #{@archive_id}")
			log_error(e)
			# this will most likely fail because the archive is just being created now. If so, just hold on
			sleep(10)
		end
	end

	  # read in the list of terms to ignore in the year field
	  @year_ignore = nil
	  begin
		  File.open("#{dir}/year_ignore.txt", "r") { |f|
			  year_ignore = f.read
			  year_ignore = year_ignore.split("\n")
			  year_ignore.delete_if { |yr| yr.strip() == '' }
			  @year_ignore = /#{year_ignore.join('|')}/
		  }
	  rescue
	  end

    ## put all of the .mrc files in the directory into an array
    marc_files = Dir["#{dir}/*.mrc"].entries
        
    ## index each file
    marc_files.each do |marc_file|
      index_file(marc_file)
      @total_record_count = @total_record_count + @file_record_count
    end
    
	  if !@rdf_path
		  @solr.commit() if !@indexer_config[:debug]
	  end

	  end_time = Time.new
	  time_lapsed = end_time - start_time
		log_progress("Indexed #{@total_record_count} MARC records in #{time_lapsed} seconds")
  end

#  def recognized_date(date)
#	  return true if date.length == 0
#	  #arr = year.scan(/(1[56789]\d[\dO]|-|\/|\sand\s|\d\d|\d)/)
#	  str = date.gsub(/\[/, '').gsub(/[\]?]/, ' ')
#	  str = str.gsub(/([Rr]e-?[Pp]rinted)|([Pp]rinted)|(Imprinted)|([Tt]he\s)|([Yy]ear)|(i.e.)|([Aa]nno)|([Dd]omini)|( [Dd]om)|([Aa]uthor)|(of)|(our)|(Lord)|([Ii]n )|(ca\.)|( or )|(present)/, ' ')
#	  str = str.gsub(/[.,]/, '')
#	  year = "\\[?1[6789]\\d[\\dO]\\??\\]?"
#	  range2 = "#{year}[-\\/]\\[?\\d\\d\\??\\]?"
#	  range4 = "#{year}\\s?-\\s?#{year}"
#	  range1 = "#{year}\/\\d"
#	  roman = "M[DCLXVI]+:?"
#	  return true if str.match(/^\s*#{year}\s*$/)
#	  return true if str.match(/^\s*#{year}\s*#{year}\s*$/)
#	  return true if str.match(/^\s*#{range4}\s*$/)
#	  return true if str.match(/^\s*#{range2}\s*$/)
#	  return true if str.match(/^\s*#{range1}\s*$/)
#	  return true if str.match(/^\s*#{roman}\s*#{year}\s*$/)
#	  return true if str.match(/^\s*#{roman}\s*#{year} #{year}\s*$/)
#	  return true if str.match(/^\s*#{roman}\s*?#{range2}\s*$/)
#	  return true if str.match(/^\s*[Bb]etween #{year}( and )|(\s*-\s*)#{year}\s*$/)
#	  log_error("Unrecognized: <#{date}|#{str}>")
#	  return false
#  end

  def index_file( marc_file )
     log_progress("Indexing #{marc_file}")
    marc_data_source = MARC::ForgivingReader.new(marc_file) #, {:forgiving => @forgiving_marc_decoding})
	 marc_data_source.set_logger(self)
    reset_progress_meter
	 tmp = marc_file.split('/')
	 @indexer_config[:prefix] = tmp.last.gsub(".mrc", '')
	indexer = SolrIndexer.new(@archive_id, marc_data_source, mapping, @indexer_config)
		indexer.set_max(@max_records) if @max_records
		this_doc = nil
#		begin
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

			  if solr_document[:federation] == nil || solr_document[:uri] == ''
				  next false
			  end

				log_url( solr_document[:uri], marc_file, solr_document[:url] )
				if @verbose
					report_record( marc_record, solr_document )
					update_progress_meter if @max_records
#				elsif @dates_only
#					date = marc_record.extract('260c')
#					date.each { |d|
#						if recognized_date(d) == false
#							 log_error("Unrecognized: #{d}")
#						end
#					}
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
#		rescue Exception => e
#			log_error("Error indexing: #{this_doc[:uri]}")
#			log_error(e)
#		end
    log_progress("Indexed #{@file_record_count} MARC records")
  end  
  
  def report_record_skipped( marc_record )
    log_progress("Record Skipped: #{parse_uri(marc_record)}")
  end
      
  def report_record( marc_record, solr_document )
    log_progress("Marc Record")
    log_progress("===========")
    log_progress(marc_record.to_s)
    log_progress("")
    log_progress("Solr Document")
    log_progress("=============")
    solr_document.keys.each do |field|
      log_progress("#{field}: #{solr_document[field]}")
    end
    log_progress("")
  end
  
  def reset_progress_meter
    @file_record_count = 0
  end

  def update_progress_meter
    @file_record_count = @file_record_count + 1
    if @file_record_count % 100 == 0
      print "."
      STDOUT.flush
		log_progress("#{@file_record_count} records.")
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
      :date_label => get_proc( :parse_date_label ),
      :year => get_proc( :parse_year ),
      :text => get_proc( :parse_text ),
      :role_PBL => get_proc( :parse_publisher ),
      :role_AUT => get_proc( :parse_author ), 
      :agent => get_proc( :parse_author ), 
      :archive => @archive_id,
      :federation => get_proc( :parse_federation ),
	  :has_full_text => "F",
	  :freeculture => "F",
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
			eighteen = true if y > 1660 && y < 1820
			nines = true if y > 1780 && y < 1930
		}
		if nines && eighteen
			return [ "NINES", "18thConnect" ]
		elsif nines && !eighteen
			return "NINES"
		elsif !nines && eighteen
			return "18thConnect"
		end
		return nil
	end

  def parse_uri( record )
    uri_formula = URI_FIELD[@archive_id]
    return parse_formula(uri_formula, record)
#    id = record.extract(URI_FIELD[@archive_id])
#    "lib://#{@archive_id}/#{id}"
  end

	def test_for_problem_record(record)
#		id = record.extract('001')
#		if id.to_s == "1373"
#			puts "problem doc"
#		end
	end
  
	def parse_title( record )
		test_for_problem_record(record)
		title = ''
		subtitle = ''

		# bancroft stores titles in weird places sometimes
		if @archive_id == 'bancroft'
			id = record.extract('001')
			title_location = TITLE_CODE_EXCEPTIONS[id.to_s]
			title = record.extract(title_location).to_s if title_location
		end
    
		if title.length == 0
			title_arr = record.extract('245a')
			if title_arr && title_arr.length > 0
				title = title_arr.join('').to_s.strip
			end
			if title.length == 0
				rec = record.extract('260a')
				if rec != nil && rec.length > 0
					title = rec.join('').to_s.strip
				end
			end
			subtitle_arr = record.extract('245b')
			subtitle = subtitle_arr.join('').to_s.strip if subtitle_arr
		end
    
		fulltitle = ''
		if subtitle.length > 0 ## if we have a subtitle, append it to the title nicely
			#if(fulltitle =~ /[:/,]$/  )
			fulltitle = title + " " + subtitle.chomp('/')
		else
			fulltitle = title.strip.chomp("/")
		end
		return fulltitle.sub(/[,;:]$/,"").strip
	end
  
  def normalize_genre_field_value( value )
    return nil if value.nil?
    normal = value.downcase
    if normal[normal.size-1] == '.' # .
      normal = normal[0..-2]
    end
    normal
  end
  
  def genre_mapper(field)
    genres = []
	return genres if field == nil
	genre = normalize_genre_field_value(field)

    [ GENRE_MAPPING, GEOGRAPHIC_MAPPING, FORMAT_MAPPING ].each do |mapping|     
      mapping.keys.each do |key|
        matching_values = mapping[key]
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
		  if subfield.kind_of?(Array)
			  subfield = subfield.join('').to_s.strip
		  end
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
  
	def extract_year( record )
		test_for_problem_record(record)
		#record.extract('260c').collect {|f| f.scan(/\d\d\d\d/)}.flatten
		years = record.extract('260c')
		result = []
		years.each {|year|
			# First remove any known garbage that is harmless
			orig_year = year
			year = year.gsub(@year_ignore, ' ')	if @year_ignore
			year = year.gsub("[", ' ').gsub("]", ' ').gsub("?", ' ').gsub(",", ' ').gsub("(", ' ').gsub(")", ' ')	# TODO-PER: change ? to a circa
			# TODO-PER: also handle <1903, c1898> <1853 c.1849 > <1909, t.p. 1910>
			arr = year.scan(/(1[56789]\d[\dO]|-|\/|\sand\s|\sor\s|\d\d|\d|circa|ca\.|ca|c)/)
			# The tokens pulled out are 4- 2- and 1-digit numbers, the hyphen, the slash, and the word 'and', or a 'c'.
			# We don't want anything before the first 4-digit number, then if the next token is hyphen, slash or 'and',
			# then we want to create a range with the first and the next number (that can be 1,2, or 4 digits). If a 4-digit number
			# follows another, then it is not a range, it is just added normally. If an unexpected sequence occurs, then just ignore it.
			# The reason unknown sequences should be ignored is that they may be part of a month and day or extra comments, so
			# it doesn't necessarily indicate an error.
			# actually, we also want a c before a 4-digit number, and a two digit number followed by 2 dashes.
			state = :start
			start_range = nil
			arr.each {|match|
				log_error("MATCH NOT ONE ELEMENT: #{match.join(',')}") if match.length != 1
				match = match[0]
				match = '' if match == nil
				case state
				when :start then
					# only accept a full date here
					if match.length == 4
						result.push(match.to_i)
						state = :divider
						start_range = match.to_i
					elsif match == 'c'
						state = :circa
					elsif match.length == 2
						state = :first_dash
						start_range = match.to_i
					end

				when :first_dash then
					if match == '-'
						state = :second_dash
					else
						state = :start
					end

				when :second_dash then
					if match == '-'
						(start_range*100).upto((start_range+1)*100) { |x|
							result.push(x)
						}
					end
					state = :start

				when :circa then
					if match.length == 4
						(match.to_i - 5).upto(match.to_i + 5) { |x|
							result.push(x)
						}
					end
					state = :start

				when :divider then
					# accept another full date, or a divider
					if match.length == 4
						result.push(match.to_i)
						state = :divider
						start_range = match.to_i
					elsif match == ' and ' || match == '/' || match == '-' || match == ' or '
						state = :range
					else
						state = :start
					end

				when :range then
					# this can be a 1-, 2-, or 4-digit number to complete the range
					num = match.to_i	# normalize the date to 4 digits
					if num > 1000
						# nothing to do
					elsif num > 9
						num = "#{start_range}"[0..1].to_i * 100 + num
					elsif num > 0
						num = "#{start_range}"[0..2].to_i * 10 + num
					end
					start_range.upto(num) {|y|
						result.push(y)
					}
					state = :start
				end
			}
			# for debugging, print out anything we didn't use
			if arr.join('').gsub(' ', '') != year.gsub(' ', '')
				log_error("Unrecognized: #{orig_year} | #{year} | #{arr.join(',')}")
			end
		}
		return { :years => result.uniq, :year_sort => result.length > 0 ? [ result[0] ] : [], :date_label => years.join(' ') }
  end  
      
  def parse_year( record )
		#years = extract_year( record )
		return @years[:years]
  end

  def parse_year_sort( record )
		#years = extract_year( record )
		#puts "SORT: #{years[:year_sort]} LABEL: #{years[:date_label]} YEARS: #{years[:years].join(',')}"
		return @years[:year_sort]
  end

	def reconstruct_date_label(years)
	# years is an array of 4-digit dates. We want to sort them, and combine the ones that are near each other with a hyphen.
		recs = years.sort
		yrs = []
		recs.each {|rec|
			rec = rec.to_i
			if yrs.length == 0
				yrs.push({ :start => rec, :end => rec })
			else
				if yrs[yrs.length-1][:end] == rec-1
					yrs[yrs.length-1][:end] = rec
				else
					yrs.push({ :start => rec, :end => rec })
				end
			end
		}
		yrs.collect! { |yr|
			if yr[:start] == yr[:end]
				yr[:start]
			else
				"#{yr[:start]}-#{yr[:end]}"
			end
		}
		#puts "=#{yrs.join(', ')}=" if recs.length > 1
		return yrs.join(', ')
	end

  def parse_date_label( record )
		@years = extract_year( record )
		#recognized_date(years[:date_label])	# for debugging the date formats that are in the marc field
		return reconstruct_date_label(@years[:years])
		#return years[:date_label]
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
#		s = parse_text( record )
#
#    return s != nil ? "F" : nil
	  return "F"
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

	def parse_estc_record( record )
		fld = record.extract('035a')
		if fld == nil || fld.length == 0
			id1 = parse_uva_id( record )
			log_error("Can't find field 035a -- skipping record #{id1}.")
			return ""
		else
			return fld[0].sub("(CU-RivES)","")
		end
	end

  def parse_formula(formula, record)
    return "" if formula.nil?

    url = ""
    formula.each do |formula_element|
      case formula_element
        when Symbol
          url << get_proc( formula_element ).call(record)
        when String
          url << formula_element
        when Array
          if formula_element.length == 1
            value = record.extract( formula_element[0] )
			if value && !value.kind_of?(String)
				value = value.join('') if value.kind_of?(Array)
				value = value.to_s if !value.kind_of?(String)
			end
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

  def parse_url( record )    
    test_for_problem_record(record)
    url_formula = URL_FORMULAE[@archive_id]
    return parse_formula(url_formula, record)
  end
  
end