#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'ruby-debug'
require 'json'
require 'geokit'

require File.dirname(__FILE__) + '/../lib/download_helper.rb'

include DownloadHelper
include Geokit::Geocoders::MultiGeocoder # for geocode

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'subpop_development',
  :username => 'root',
  :host     => 'localhost'
)

# this gets us what we need in the local DB
class Asset < ActiveRecord::Base; end
class Video < Asset; end
class Audio < Asset; end
class Image < Asset; end
class Party < ActiveRecord::Base; end
class Arist < Party; end
class Release < ActiveRecord::Base; end
class Track < ActiveRecord::Base; end

unless infile = $1 and File.exists? infile
  warn "usage: #{$0} <input file>"
  exit 1
end

File.open(infile).each do |line|
   if match = line.match(S3.RE) 
     # see DownloadHelper::S3 for match format
     # pull asset and id from mp3 filename, bail otherwise
     next unless asset_id = match[7].match(/(\d+)\.mp3$/i)[1]
     next unless asset = Asset.find_by_id(asset_id)

     track   = Track.find_by_title(asset.title)
     release = track.nil? ? Release.new : track.release

     # fallback empty loc used to generate correct JSON
     null_loc = loc_to_hash Geokit::GeoLoc.new

     if ref_ip = get_referrer_ip(match[10])
       ref_loc = loc_to_hash geocode(ref_ip)
     else
       ref_loc = null_loc
     end

     req_loq = loc_to_hash geocode(match[5]) || null_loc
  
     out = {
       :artist   => asset.artist.name,
       :title    => asset.title,
       :release  => release.title,
       :date     => match[3],
       :format   => "mp3",
       :referrer_location => ref_loc,
       :request_location  => req_loc
     }
     puts JSON.generate(out)
   end
end

__END__

Example log entry:

log-2009-05-25.log:49864fa63c0fff21053c90a83cf9ef8d0567b7a51c2208590adf03a007f8c572 subpop-public [25/May/2009:12:42:02 +0000] 78.52.62.37 65a011a29cdf8ec533ec3d1ccaae921c 9DC594F260C02C46 REST.GET.OBJECT samplers/sub_pop_cybersex_2009.zip "GET /samplers/sub_pop_cybersex_2009.zip HTTP/1.1" 200 - 82103294 82103294 153324 358 "http://www.nicorola.de/aktuelle-beitrage/musik/mp3/kostenloser-subpop-sampler" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; de; rv:1.9.0.10) Gecko/2009042315 Firefox/3.0.10"

Example JSON output:

{
  "release":"In Name and Blood",
  "format":"exe",
  "date":"2000-07-06",
  "artist":"Murder City Devils",
  "referrer_location": {
    "lng":null,
    "country_code":null,
    "zip":null,
    "state":null,
    "city":null,
    "lat":null
  },
  "request_location": {
    "lng":null,
    "country_code":null,
    "zip":null,
    "state":null,
    "city":null,
    "lat":null
  },
  "title":"Murder City Devils / Yo-Yos Tour e-card"
}
