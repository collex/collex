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
class Admin::SetupsController < Admin::BaseController
	# GET /setups
	# GET /setups.xml
	def index
		setups = Setup.all
		@setups = {}
		setups.each { |setup| @setups[setup.key] = setup.value }
	end

	# PUT /setups/1
	# PUT /setups/1.xml
	def update
		msg = ""
		act = params['commit']
		default_federation = nil

    checkbox_keys = ['enable_community_tab', 'enable_publications_tab', 'enable_classroom_tab', 'enable_news_tab']
    checkbox_keys.each { |key,value|
      rec = Setup.find_by_key(key)
      if rec
        rec.value = 'false'
        rec.save!
      end
    }


		params['setups'].each { |key,value|
			rec = Setup.find_by_key(key)
			if rec
				default_federation = value if key == 'site_default_federation'
        if checkbox_keys.include? rec.key
          rec.value = 'true'
        else
          if value.strip == ''
            rec.value = get_default_value(key)
          else
            rec.value = value
          end
        end
				rec.save!
			else
				Setup.create({ key: key, value: value })
			end
		}
		Setup.reload()
		refill_session_cache()


		if act == 'Send Me A Test Email'
			user = get_curr_user()
			GenericMailer.generic(Setup.site_name(), Setup.return_email(), user[:fullname], user[:email], "Test Email From Collex",
				"If you are reading this, then the email settings are correct in Collex. ",
				url_for(:controller => '/home', :action => 'index', :only_path => false), 
				"\n--------------\nAutomatic Email from Collex").deliver
			msg = "An email should have been sent to the email address on your account."
		elsif act == 'Simulate Error Email'
			raise("This is a test of the error notification system. An administrator pushed the Simulate Error button. If you are reading this, then the error notification system is working correctly.")
		elsif act == 'Test Catalog Connection'
			begin
				solr = Catalog.factory_create(session[:use_test_index] == "true")
				federations = solr.get_federations()
				found = false
				federations.each { |key,val| found = true if default_federation == key }
				if found == true
					msg = "The connection to the Catalog is good."
				else
					msg = "The connection to the Catalog is good, but the federation \"#{default_federation}\" was not found." +
						" The possible federations are: #{federations.map {|key,val| key }.to_s }"
				end
			rescue Catalog::Error => e
				msg = "There is a problem with the connection to the Catalog. Is the URL you've specified correct?"
			end
    else
      warnings = verify_setup_values()
      if warnings.length == 0
        msg = "Parameters successfully updated."
      else
        msg = "Warning:"
      end
    end
    flash[:notice] = msg
    flash[:warnings] = warnings
		redirect_to :back
  end

  private
  def get_default_value(key)
    value = ''
    case key
      when 'facet_display_name_discipline'
        value = "Discipline"
      when 'facet_display_name_format'
        value = "Format"
      when 'facet_display_name_genre'
        value = "Genre"
      when 'facet_display_name_access'
        value = "Access"
      else
        value = value
    end
    return value
  end

  def verify_setup_values()
    warnings = []

    order = {}
    rec = Setup.find_by_key('facet_order_format')
    order['facet_order_format'] = rec.value
    rec = Setup.find_by_key('facet_order_access')
    order['facet_order_access'] = rec.value
    rec = Setup.find_by_key('facet_order_discipline')
    order['facet_order_discipline'] = rec.value
    rec = Setup.find_by_key('facet_order_genre')
    order['facet_order_genre'] = rec.value

    # Check for duplicate values
    if order.values.count != order.values.uniq.count
      warnings.push 'Facet Display Order contains duplicate numbers. Facets may not display correctly.'
      if order.values.count(order['facet_order_genre']) > 1
        warnings.push " Genre Facet Order: #{order['facet_order_genre']}"
      end
      if order.values.count(order['facet_order_discipline']) > 1
        warnings.push " Discipline Facet Order: #{order['facet_order_discipline']}"
      end
      if order.values.count(order['facet_order_access']) > 1
        warnings.push " Access Facet Order: #{order['facet_order_access']}"
      end
      if order.values.count(order['facet_order_format']) > 1
        warnings.push " Format Facet Order: #{order['facet_order_format']}"
      end
    end

    # Check for non-numeric values
    access_order, genre_order, discipline_order, format_order = nil, nil, nil, nil
    begin
      access_order = Integer(order['facet_order_access']) if order['facet_order_access'].length > 0
    rescue
      warnings.push( "NonNumeric Display Order detected. \"Access Facet Order: #{order['facet_order_access']}\" Facets may not display correctly.")
    end
    begin
      genre_order = Integer(order['facet_order_genre']) if order['facet_order_genre'].length > 0
    rescue
      warnings.push( "NonNumeric Display Order detected. \"Genre Facet Order: #{order['facet_order_genre']}\" Facets may not display correctly.")
    end
    begin
      discipline_order = Integer(order['facet_order_discipline']) if order['facet_order_discipline'].length > 0
    rescue
      warnings.push( "NonNumeric Display Order detected. \"Discipline Facet Order: #{order['facet_order_discipline']}\" Facets may not display correctly.")
    end
    begin
      format_order = Integer(order['facet_order_format']) if order['facet_order_format'].length > 0
    rescue
      warnings.push( "Non Numeric Display Order detected. \"Format Facet Order: #{order['facet_order_format']}\" Facets may not display correctly.")
    end

    if !access_order.nil? and access_order > 4
      warnings.push("Large value detected. \"Access Facet Order: #{order['facet_order_access']}\"  Facets may not display correctly.")
    end
    if !genre_order.nil? and genre_order > 4
      warnings.push("Large value detected. \"Genre Facet Order: #{order['facet_order_genre']}\" Facets may not display correctly.")
    end
    if !discipline_order.nil? and discipline_order > 4
      warnings.push("Large value detected. \"Discipline Facet Order: #{order['facet_order_discipline']}\" Facets may not display correctly.")
    end
    if !format_order.nil? and format_order > 4
      warnings.push("Large value detected. \"Format Facet Order: #{order['facet_order_format']}\" Facets may not display correctly.")
    end

    if !access_order.nil? and access_order < 0
      warnings.push("Negative value detected. \"Access Facet Order: #{order['facet_order_access']}\"  Facets may not display correctly.")
    end
    if !genre_order.nil? and genre_order < 0
      warnings.push("Negative value detected. \"Genre Facet Order: #{order['facet_order_genre']}\" Facets may not display correctly.")
    end
    if !discipline_order.nil? and discipline_order < 0
      warnings.push("Negative value detected. \"Discipline Facet Order: #{order['facet_order_discipline']}\" Facets may not display correctly.")
    end
    if !format_order.nil? and format_order < 0
      warnings.push("Negative value detected. \"Format Facet Order: #{order['facet_order_format']}\" Facets may not display correctly.")
    end




    return warnings

  end

end
