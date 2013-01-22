MY_COLLEX_URL = SITE_SPECIFIC['my_collex_url']
SKIN = SITE_SPECIFIC['skin']

DEFAULT_THUMBNAIL_IMAGE_PATH = "#{SKIN}/sm_site_image.#{SKIN=='mesa' ? 'jpg' : 'gif'}"
LARGE_THUMBNAIL_IMAGE_PATH = "#{SKIN}/lg_site_image.#{SKIN=='mesa' ? 'jpg' : 'gif'}"
PROGRESS_SPINNER_PATH = "ajax_loader.gif"
SPINNER_TIMEOUT_PATH = "#{SKIN}/no_image.jpg"

DISALLOW_RSS = SITE_SPECIFIC['disallow_rss'].blank? ? false : SITE_SPECIFIC['disallow_rss']
BLEEDING_EDGE = SITE_SPECIFIC['bleeding_edge']
