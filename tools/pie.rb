#!/usr/bin/env ruby
require 'rubygems'
require 'sparklines'

0.upto(100) do |i|
   Sparklines.plot_to_file("public/images/pie_#{i}.png",
           [i],  :type => 'pie',
           :background_color => "#ededed", :share_color => "#a60000", :remain_color => "#dcdcdc"
   )
end
