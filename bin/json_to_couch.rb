#!/usr/bin/env ruby
require 'digest/md5'

COUCH_HOST  = "http://127.0.0.1:5984"
DB          = "dxarts"

ARGF.each do |line|
  line.chomp!
  # (s)hell quoting
  line.gsub!(/["]/, '\\\"')
  line.gsub!(/[']/, '\\\\\'')
  uuid = Digest::MD5.hexdigest(line)
  cmd = "curl -X PUT #{COUCH_HOST}/#{DB}/#{uuid} -d \"#{line}\""
  puts cmd
  `#{cmd}`
end
