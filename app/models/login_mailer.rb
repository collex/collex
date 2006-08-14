class LoginMailer < ActionMailer::Base

  helper ActionView::Helpers::UrlHelper

  def password_reset(params)
    @subject    = 'Collex Password Reset'
    @body       = params
    @recipients = params[:user][:email]
    @from       = 'mailto:technologies@nines.org'
    @headers    = {}
  end
end
