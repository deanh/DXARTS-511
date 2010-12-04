#!/usr/bin/env ruby

require 'rubygems'
require 'ruby-debug'
require 'json'
require 'geokit'
require 'pp'

gem 'activerecord', '= 2.3.8'
require 'active_record'  # ?

require File.dirname(__FILE__) + '/../lib/hostip.rb'
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

File.open(infile).each do |line|
  if match = line.match(S3.RE) 
    # see DownloadHelper::S3 for match format
    # pull asset and id from mp3 filename, bail otherwise
    next unless asset_match = match[7].match(/(\d+)\.mp3$/i)
    next unless asset = Asset.find_by_id(asset_match[1])

    next unless track = Track.find_by_title(asset.title)
    next unless release = track.nil? ? Release.new : track.release

    ref_ip = get_referrer_ip(match[10])

    date, time = S3.format_date(match[3])
    req_loc = Hostip.geocode(match[5]) || null_loc

    out = {
      :artist   => track.artist ? track.artist.name : nil,
      :title    => asset.title,
      :source   => "s3",
      :release  => release.title,
      :date     => date,
      :time     => time,
      :format   => "mp3",
      :referrer => {
        :url      => match[10],
        :host     => referrer_host(match[10]),
        :host_ip  => ref_ip,
      },
      :request_location  => req_loc
    }
    puts JSON.generate(out)
  end
end
