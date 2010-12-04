#!/usr/bin/env ruby
require 'digest/md5'
require 'rubygems'
require 'net/http/persistent'

COUCH_HOST  = "http://localhost:5984"
DB          = "downloads"
BASE_URL    = COUCH_HOST + "/" + DB

STDOUT.sync = true

cnt         = 0
http        = Net::HTTP::Persistent.new
retries     = 0

ARGF.each do |line|
  next if line =~ /^Host/
  puts "\nProcessed: #{cnt}" if cnt % 10000 == 0

  begin
    line.chomp!
    uuid     = Digest::MD5.hexdigest line
    uri      = URI.parse "#{BASE_URL}/#{uuid}"
    put      = Net::HTTP::Put.new uri.path
    put.body = line
    res = http.request uri, put
 
    if res.code != "201" and retries < 4
      retries += 1
      redo
    elsif (res.code != "201" and retries >= 4)
      print "*"
      puts line
      next
    end

    print "."
  rescue
    STDERR.puts "ERROR: for #{line}" 
  end

  cnt    += 1
  retries = 0
end
