#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'ruby-debug'
require 'json'
require 'geokit'

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

def get_referrer_ip(ref)
  # strip protocol and query string
  ref.sub!(/http:\/\/([^\/?]+).*/, $1)
  # IP lookup. q & d
  return ref if ref =~ /^\d+\.\d+\.\d+\.\d+$/
  `host #{s}`.match(/\d+\.\d+\.\d+\.\d+/)[0]
end

Download.find_in_batches(:batch_size => 1000) do |batch|
  batch.each do |dl|
    m   = Multimedia.find(dl.mid)
    ip  = get_referrer_ip(dl.referrer)
    loc = Geokit::Geocoders::MultiGeocoder.geocode(ip)
    
    loc_hash = { 
      :lat => loc.lat,
      :lng => loc.lng,
      :country_code => loc.country_code,
      :state        => loc.state,
      :city         => loc.city,
      :zip          => loc.zip
    }

    out = {
      :artist   => m.bandname,
      :title    => m.title,
      :release  => m.release_name,
      :date     => dl.date,
      :format   => m.format,
      :location => loc_hash
    }
    puts JSON.generate(out)
  end
end

 
