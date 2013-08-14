class DocumentCompleteMailer < ActionMailer::Base
  default from: Setup.return_email()
  
  def document_complete_email( user, document, doc_url, status_url, admins)
    @user = user.username
    @title = document.title
    @uri = document.uri
    @doc_url = doc_url
    @status_url = status_url
    email_list = ""
   
    mail(:to => admins, :subject => "TypeWright Document Complete") 
  end
end
