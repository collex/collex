class VicConferenceController < ApplicationController
	def create
		str = ""
		params[:registration].each {|k, v|
			str += "#{k}: #{v}<br />"
		}
		redirect_to "/VIC2010/confirmation.html"
		#redirect_to "https://roth.itc.virginia.edu/ccgate/servlet/CCControl"
#merchant
#Charge Amount
#Numerical, with two decimal places, i.e. 999.99
#amount
#Order Number
#alphanumeric, 10 characters max, should be unique for merchant
#orderNumber
#Return URL for return-to-dept button
#legal URL
#backURL
		#render :text => "VicConferenceController#create<br />#{str}"
	end
end
