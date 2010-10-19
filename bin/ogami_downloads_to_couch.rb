#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'ruby-debug'
require 'json'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'ogami',
  :username => 'root',
  :host     => 'localhost'
)

class Download < ActiveRecord::Base; end
class Multimedia < ActiveRecord::Base
  set_table_name "multimedia"
end

Download.find(:all, :limit => 10) do |dl|
  m = Multimedia.find(dl.mid)
  out = {
    :artist   => m.bandname,
    :title    => m.title,
    :release  => m.release_name,
    :date     => dl.date,
    :format   => m.format
  }
  puts JSON.generate(out)
end

 
