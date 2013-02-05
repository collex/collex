# Define Plugins

plugins = SITE_SPECIFIC['plugins'] || { }
plugins.delete_if { |key, value| value != true }

plugins.each { |key, value|
	params = SITE_SPECIFIC[key]
	params = { } if params == nil
	params[:name] = key
	plugins[key] = params
}
COLLEX_PLUGINS = plugins
