#!/usr/bin/env ruby
$-w = true

require 'dbm'
require 'pp'

@dbm = DBM.new("date_artist_title.db")
current_date = nil
hsh          = {}

def next_date(cnt_hsh, curr_date)
  @dbm[curr_date] = Marshal.dump cnt_hsh
  puts "  {\n    #{curr_date}:\n    {"
  cnt_hsh.each do |k,v|
    artist = k.match(/"artist":"([^"]+)"/) ? $1 : ""
    title  = k.match(/"title":"([^"]+)"/)  ? $1 : ""
    puts "      \"#{artist} | #{title}\": #{v},"
  end
  puts "    }\n  },"
end

puts "[\n"

ARGF.each do |l|
  next unless l =~ /^"date/ 
  ar = l.chomp.split(',')
  if ar[0] != current_date
    next_date(hsh, current_date) if current_date
    hsh = {}
    current_date = ar[0]
  end

  if hsh["#{ar[1]},#{ar[2]}"]
    hsh["#{ar[1]},#{ar[2]}"] += 1
  else
    hsh["#{ar[1]},#{ar[2]}"] = 1
  end
end

next_date(hsh, current_date)

puts "]"
