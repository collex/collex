MARCEXT library - extends the MARC library by providing useful mixins
Requires: MARC Gem & Linguistics Gem
Authors:
	Matt Mitchell - mwm4n@virginia.edu
	Bess Sadler - eos8d@virginia.edu

Example:
require 'marc_ext'
require 'marc_ext/record'
class MARC::Record
	include MARCEXT::Record
end