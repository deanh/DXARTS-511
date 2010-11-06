#!/usr/bin/env ruby

require 'rubygems'
require 'ruby-debug'
require 'json'
require 'geokit'
require 'pp'

#gem 'activerecord', '= 2.3.8'
require 'active_record'  # ?

require File.dirname(__FILE__) + '/../lib/download_helper.rb'

include DownloadHelper
include Geokit::Geocoders # for geocode

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
class Artist < Party; end
class Release < ActiveRecord::Base
  has_many :tracks
end
class Track < ActiveRecord::Base
  belongs_to :release
  belongs_to :artist
end

unless infile = ARGV[0] and File.exists? infile
  warn "usage: #{$0} <input file>"
  exit 1
end

File.open(infile).each do |line|
   if match = line.match(S3.RE) 
     # see DownloadHelper::S3 for match format
     # pull asset and id from mp3 filename, bail otherwise
     next unless asset_match = match[7].match(/(\d+)\.mp3$/i)
     next unless asset = Asset.find_by_id(asset_match[1])

     next unless track = Track.find_by_title(asset.title)
     release = track.nil? ? Release.new : track.release

     # fallback empty loc used to generate correct JSON
     null_loc = loc_to_hash Geokit::GeoLoc.new

     if ref_ip = get_referrer_ip(match[10])
       ref_loc = loc_to_hash MultiGeocoder.geocode(ref_ip)
     else
        ref_loc = null_loc
     end

     req_loc = loc_to_hash MultiGeocoder.geocode(match[5]) || null_loc

     out = {
       :artist   => track.artist.name,
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
