class DocumentCompleteMailer < ActionMailer::Base
  #default from: globals()['sender_email']
  
  def document_complete_email( user, document, doc_url, status_url, admins)
    @user = user.username
    @title = document.title
    @doc_url = doc_url
    @status_url = status_url
    email_list = ""
    
    mail(:to => admins, :subject => "TypeWright Document Complete", :from=>@user) 
  end
end
