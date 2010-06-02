class VicConferenceController < ApplicationController
	def auth
		order = params[:orderNumber]
		order = order.split('-')
		id = order[1].to_i / 53
		rec = VicConference.find(id)
		rec.update_attributes(:amt_paid => params[:amount], :auth_status => params[:authStatus], :auth_code => params[:avsCode], :error_txt => params[:errorTxt])
		params.each { |k,v|
			puts "#{k}: #{v}"
		}

		render :text => "ok"
	end

	def make_confirm_line(label, value)
		return "<div><span class='confirm_label'>#{label}:</span> <span class='confirm_value'>#{value}</span></div>\n"
	end

	def create
		html = <<END_OF_STRING
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <link href="/VIC2010/vij.css" media="all" rel="stylesheet" type="text/css"/>
  <style type="text/css">
  a{color:#00c}a:active{color:#f00}a:visited{color:#551a8b}table{border-collapse:collapse;border-width:0;empty-cells:show}ul{padding:0 0 1em 1em}ol{padding:0 0 1em 1.3em}li{line-height:1.5em;padding:0 0 .5em 0}p{padding:0 0 1em 0}h1,h2,h3,h4,h5{padding:0 0 1em 0}h1,h2{font-size:1.3em}h3{font-size:1.1em}h4,h5,table{font-size:1em}sup,sub{font-size:.7em}input,select,textarea,option{font-family:inherit;font-size:inherit}.g-doc,.g-doc-1024,.g-doc-800{font-size:130%}.ss-base-body{font-size:.8em}.ss-textarea{max-width:99%}.ss-choice-item{margin:0;line-height:1.3em;padding-bottom:.5em}.ss-form-entry input{vertical-align:middle;margin-top:0}.g{color:#666}.i{display:inline}.ss-form-desc{font:inherit;white-space:pre-wrap;white-space:-moz-pre-wrap;word-wrap:break-word;width:99%;margin:0}.ss-q-title{display:block;font-weight:bold}.ss-q-help{display:block;color:#666;margin:.1em 0 .25em 0}.ss-q-long{max-width:90%}.ss-form-entry{margin-bottom:1.5em;zoom:1;}.ss-choices{list-style:none;margin:.5em 0 0 0;padding:0}.ss-powered-by{display:block;clear:left;color:#666;margin:1em 0.2em 0.2em}.ss-powered-by a:link,.ss-powered-by a:visited{color:#666}.ss-terms{display:block;clear:left;margin:1em 0.2em 0.2em}.ss-required-asterisk{color:#c43b1d}.ss-section-title{background-color:#eee;padding:0.4em;margin:2em -0.4em 0}.ss-section-description{margin-top:0.5em}.ss-page-number{color:#666;line-height:2em}hr{background-color:#ccc;height:2px;border-width:0;margin:0 -2em}.ie hr{width:107%}.ss-page-title{margin:0;padding:0}.ss-gridnumbers{text-align:center;border-bottom:1px solid #d3d8d3}.ss-gridnumber{display:block;padding:0.5em 0 .5em}.ss-gridrow{text-align:center;color:#666;border-bottom:1px solid #d3d8d3;padding:.5em .25em}.ss-grid-row-even{background-color:#fff}.ss-grid-row-odd{background-color:#f2f2f2}.ss-gridrow-leftlabel{padding:0 1em}.ss-grideditor-columns input{line-height:150%}.ss-grideditor-editor .ss-magiclist-ul span.ss-header{font-weight:bold;padding-right:1em}.ss-grid .errorbox-component .errorbox-good,.ss-grid .errorbox-component .errorbox-bad{display:none}.ss-scalenumbers{text-align:center}.ss-scalenumber{display:block;padding:0.5em 0 .5em}.ss-scalerow{text-align:center;color:#666;border:1px solid #d3d8d3;border-left:0;border-right:0;padding:.5em .25em}td.ss-leftlabel{text-align:right;padding-left:0}td.ss-rightlabel{text-align:left;padding-right:0}.errorbox-bad{border:2px solid #c43b1d;background-color:#ffe6cc;padding:2px}.errorheader{color:#c43b1d}
  </style>
  <style type="text/css">
@import "//themes.googleusercontent.com/fonts/css?kit=75iFw6DSXGGp56YRAJl-Dl7am2uOAgh5xRFulfZHPqxnhV2whvSe3L0PRVRfs8A5";
.ss-form-body { background-color: #563708; padding: 1px 20px; }
  h1,h2,h3,h4,h5,h6,p,ul,ol,li,div,td,label{line-height:20px;margin:0;padding:0}br{display:none}input,select,textarea{font-family:Tahoma,Arial,serif;font-size:13px}div.ss-form-container{background:#fffefa url('//lh3.googleusercontent.com/tIv9r1cf6jJs5juc9-ctA4gQoOvEq_D0N4qtQBZKq4_Ak6tmEMxiO2mYpDl_6rXbRnLhxim8Xu4pdJzDG9zp8hQ=s0');border:1px solid #d4c7b4;font-size:14px;line-height:1.6em;margin:20px auto;max-width:800px;padding:20px 40px 20px 20px;width:auto}div.ss-form-heading{text-align:center}.ss-required-asterisk{color:#c00}h1,h2{font-family:Tangerine}h1.ss-form-title{background:url('//lh3.googleusercontent.com/Kqrh8GmHf75HRBU_0qjZ63vuCwGOyUBTVyn26V6wI7ghhe3odT1ENOWbzG9Bpw1uKXgt2yHpcxzA2IuchbgkApA=s0') bottom center no-repeat;font-size:48px;font-weight:normal;line-height:52px;margin:0 0 10px;padding:0 0 25px}div.errorbox-bad{background:none;border:none;padding:0}div.errorheader,div.errorbox-bad div.ss-form-entry{background:#fee;border:1px solid #ebb;color:#c00;padding:5px}div.ss-form-entry{margin:0 0 20px}div.ss-section-header div.ss-form-entry,div.ss-navigate div.ss-form-entry{background:none;padding:0;margin:0}div.ss-section-header,div.ss-page-break{background:url('//lh3.googleusercontent.com/Kqrh8GmHf75HRBU_0qjZ63vuCwGOyUBTVyn26V6wI7ghhe3odT1ENOWbzG9Bpw1uKXgt2yHpcxzA2IuchbgkApA=s0') bottom center no-repeat;margin:10px 0;padding:0 0 25px;text-align:center}h2.ss-section-title,h2.ss-page-title{background:none;font-size:36px;font-weight:normal;line-height:42px;margin:0;padding:0}div.ss-section-description{margin:0}label.ss-q-help{font-style:italic;margin:0}.ss-required-asterisk{color:#c00}input.ss-q-short,textarea.ss-q-long,select,input.ss-q-other,input.ss-q-checkbox{border:1px solid #ddd0cc}label.ss-scalenumber{padding:0}td.ss-scalenumbers,td.ss-scalerow,td.ss-gridnumbers,td.ss-gridrow{border-color:#ddd0cc}tr.ss-grid-row-odd{background:url('//lh3.googleusercontent.com/4t24Vmm0aqZMjMWOgYUuhYbrfdcsJRI9ezsVZHR56MoVby8L80m8cCsusuQjDeNrIemSj6vXz7Fsf1IBq4iOwaQ=s0')}tr.ss-grid-row-even{background:none}
.confirm_label {
    font-weight: bold;
    float: left;
    position: absolute;
}

.confirm_value {
    padding-left: 250px;
}

.ss-form div {
    padding-top: 8px;
    padding-bottom: 8px;
}
  </style>

  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <title>The Victorians Institute Conference: Review Registration</title>
 </head>
 <body>

  <div id="contents">
  <div id="navbar">
   <a id="home" href="/VIC2010/index.html"> Home </a>
   <b>|</b>
   <a href="/VIC2010/travel.html"> Travel and Accommodations </a>
   <b>|</b>
   <a href="/VIC2010/program.html"> Program </a>
   <b>|</b>
   <a href="/VIC2010/registration.html"> Registration </a>
   <b>|</b>
   <a href="http://www.vcu.edu/vij/"> <i>VI home</i> </a>
  </div>
  <div id="container">
	<div id="form">
		<div class="ss-form-body"><div class="ss-form-container">
			<div class="ss-form-heading">
				<h1 class="ss-form-title">Review Registration</h1>
				<p></p>
				<div class="ss-form-desc">By The Numbers: Victorians Institute Conference 2010 at the University of Virginia October 1-3, 2010</div>
				<p></p>
				<hr class="ss-email-break" style="display: none;"/>
			</div>
			<div class="ss-form">
				<form action="https://roth.itc.virginia.edu/ccgate/servlet/CCControl" method="POST" id="ss-form">
				<input  type="hidden" value="nines-conference" name="merchant" />
				<input  type="hidden" value="$AMOUNT.00" name="amount" />
				<input  type="hidden" value="$ORDERNUMBER" name="orderNumber" />
				<input  type="hidden" value="http://nines.org/VIC2010" name="backURL" />
				<input  type="hidden" value="Victorians Institute Conference 2010" name="description" />
				<input  type="hidden" value="$FIRSTNAME" name="firstName" />
				<input  type="hidden" value="$LASTNAME" name="otherName" />
				<input  type="hidden" value="$EMAILADDR" name="emailAddr" />
				$REPLACE_ME
				<div class="ss-item ss-navigate">
					<div class="ss-form-entry">
						<input name="submit" value="Pay Now" type="submit" />
					</div>
				</div>
				</form>
			</div>
		</div>
  </div></div>
  </div>
  </div>
  </body>
</html>
END_OF_STRING
		values = params[:registration]
		rec = VicConference.create(values)
		if values
			str = ""
			if values[:price] == 'faculty'
				amt = "70"
				str += make_confirm_line("Registration Type", "Faculty ($70)")
			else
				amt = "40"
				str += make_confirm_line("Registration Type", "Student ($40)")
			end
			str += make_confirm_line("First Name", values[:first_name])
			str += make_confirm_line("Last Name", values[:last_name])
			str += make_confirm_line("University", values[:university])
			str += make_confirm_line("Email", values[:email])
			str += make_confirm_line("Phone", values[:phone])
			str += make_confirm_line("Title of Presentation", values[:title]) if values[:title] && values[:title].length > 0
			str += make_confirm_line("Accessibility Needs", values[:accessibility]) if values[:accessibility] && values[:accessibility].length > 0
			str += make_confirm_line("Audio/Visual Needs", values[:audio_visual]) if values[:audio_visual] && values[:audio_visual].length > 0
			str += make_confirm_line("Rare Book School seminar registration", values[:rare_book_school_1])
			str += make_confirm_line("Seminar Registration Second choice", values[:rare_book_school_2])
			str += make_confirm_line("Lunch Friday", values[:lunch_friday] ? "Yes" : "No")
			str += make_confirm_line("Lunch Saturday", values[:lunch_saturday] ? "Yes" : "No")
			str += make_confirm_line("Vegetarian", values[:lunch_vegetarian] ? "Yes" : "No")
			str += make_confirm_line("Parking", values[:parking] ? "Yes" : "No")
			html = html.sub("$REPLACE_ME", str)

			#test_num = (rec.id % 3) + 1	# test mode only accepts a 1 2 or 3 as the first digit.

			html = html.sub("$AMOUNT", "#{amt}")
			str = "vic-#{rec.id*53}"
			html = html.sub("$ORDERNUMBER", str)
			html = html.sub("$FIRSTNAME", values[:first_name])
			html = html.sub("$LASTNAME", values[:last_name])
			html = html.sub("$EMAILADDR", values[:email])
		end
		render :text => html
	end
end
