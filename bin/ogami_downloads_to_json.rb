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

# def get_referrer_ip(ref)
#   return if ref == nil
# 
#   # strip protocol and query string
#   if md = ref.match(/http:\/\/([^\/?]*).*/)
#     ref = md[1]
#   end
#   #ref.sub!(/http:\/\/([^\/?]*).*/, $1) if ref =~ /^http:/
#   # IP lookup. q & d
# 
#   return case
#          when ref == nil                   : nil
#          when ref == ''                    : nil
#          when ref =~ /^\s+$/               : nil
#          when ref =~ /^\d+\.\d+\.\d+\.\d+$/: ref
#          else
#            begin
#              `host #{ref}`.match(/\d+\.\d+\.\d+\.\d+/)[0]
#            rescue
#            end 
#          end
# end
# 
# def loc_to_hash(loc)
#     loc_hash = { 
#       :lat => loc.lat,
#       :lng => loc.lng,
#       :country_code => loc.country_code,
#       :state        => loc.state,
#       :city         => loc.city,
#       :zip          => loc.zip
#     }
# end

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

 
