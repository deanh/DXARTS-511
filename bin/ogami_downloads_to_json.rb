#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'ruby-debug'
require 'json'
require 'geokit'

require File.dirname(__FILE__) + '/../lib/download_helper.rb'

include DownloadHelper

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'subpop-ogami',
  :username => 'root',
  :host     => 'localhost'
)

class Download < ActiveRecord::Base; end
class Multimedia < ActiveRecord::Base
  set_table_name "multimedia"
end

Download.find_in_batches(:batch_size => 1000) do |batch|
  batch.each do |dl|
    m   = Multimedia.find(dl.mid)
    null_loc = loc_to_hash Geokit::GeoLoc.new

    if ip = get_referrer_ip(dl.referrer)
      loc = loc_to_hash Geokit::Geocoders::MultiGeocoder.geocode(ip)
    else
      loc = null_loc
    end

    out = {
      :artist   => m.bandname,
      :title    => m.title,
      :release  => m.release_name,
      :date     => dl.date,
      :format   => m.format,
      :referrer_location => loc,
      :request_location  => null_loc
    }
    puts JSON.generate(out)
  end
end

 
