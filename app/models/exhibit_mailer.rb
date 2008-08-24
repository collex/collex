class ExhibitMailer < ActionMailer::Base

  def published_notification(exhibit)
    @recipients   = EXHIBITS_CONF[:publish_recipients]
    @from         = 'notifier@nines.org'
    headers         "Reply-to" => "#{EXHIBITS_CONF[:publish_recipients]}"
    @subject      = "NINES EXHIBIT (#{RAILS_ENV}) #{exhibit.title} has been published."
    @sent_on      = Time.now
    @content_type = "text/plain"
 
    body :exhibit => exhibit   
  end
  
  def unpublished_notification(exhibit)
    @recipients   = EXHIBITS_CONF[:publish_recipients]
    @from         = 'notifier@nines.org'
    headers         "Reply-to" => "#{EXHIBITS_CONF[:publish_recipients]}"
    @subject      = "NINES EXHIBIT (#{RAILS_ENV}) #{exhibit.title} has been UN-published."
    @sent_on      = Time.now
    @content_type = "text/plain"
 
    body :exhibit => exhibit   
  end
end
