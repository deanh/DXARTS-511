#!/usr/bin/env ruby

require 'rubygems'
require 'active_record'
require 'ruby-debug'
require 'json'

require File.dirname(__FILE__) + '/../lib/hostip.rb'
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

file_num  = 0
batch_num = 0
file = File.new("ogami-#{file_num}.json", "w")

Download.find_in_batches(:batch_size => 10000) do |batch|

  if (batch_num % 10 == 0)
    file_num += 1
    file = File.new("ogami-#{file_num}.json", "w")
    puts "File num: #{file_num}"
  end

  batch.each do |dl|
    next if dl.mid < 100
    m   = Multimedia.find(dl.mid)
    ip = get_referrer_ip(dl.referrer)

    out = {
      :artist   => m.bandname,
      :title    => m.title,
      :source   => "ogami",
      :release  => m.release_name,
      :date     => dl.date,
      :time     => nil,
      :format   => m.format,
      :referrer => {
        :url      => dl.referrer,
        :host     => referrer_host(dl.referrer),
        :host_ip  => ip
      },
      :request_location  => null_loc
    }
    file.write "#{JSON.generate(out)}\n"
  end
  puts "Finished batch: #{batch_num}"
  batch_num += 1
end

 
