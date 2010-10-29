#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'ruby-debug'
require 'json'
require 'geokit'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'subpop-development',
  :username => 'root',
  :host     => 'localhost'
)

class Asset < ActiveRecord::Base; end
class Party < ActiveRecord::Base; end
class Release < ActiveRecord::Base; end
class Track < ActiveRecord::Base; end

# regex to parse loggiles and store apropriate data
re = %r{
  ^(\S+)\s                # 1: log id
  (\S+)\s                 # 2: bucket-name
  \[(\S+)\s(\S+)\]\s      # 3: date time is first capture, 4: UTC offset next
  (\d+\.\d+\.\d+\.\d+)\s  # 5: requesting IP
  \S+\s
  \S+\s
  (\S+)\s                 # 6: s3 API call (?)
  (\S+)\s                 # 7: filename
  "([^"]+)"\s             # 8: HTTP request inside "
  (\d+)\s                 # 9: HTTP status
  -\s\d+\s\d+\s\d+\s\d+\s # line noise
  "([^"]+)"\s             # 10: referrer inside "
  "([^"]+)"               # 11: user-agent inside "
}x

__END__

Example log entry:

log-2009-05-25.log:49864fa63c0fff21053c90a83cf9ef8d0567b7a51c2208590adf03a007f8c572 subpop-public [25/May/2009:12:42:02 +0000] 78.52.62.37 65a011a29cdf8ec533ec3d1ccaae921c 9DC594F260C02C46 REST.GET.OBJECT samplers/sub_pop_cybersex_2009.zip "GET /samplers/sub_pop_cybersex_2009.zip HTTP/1.1" 200 - 82103294 82103294 153324 358 "http://www.nicorola.de/aktuelle-beitrage/musik/mp3/kostenloser-subpop-sampler" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; de; rv:1.9.0.10) Gecko/2009042315 Firefox/3.0.10"
