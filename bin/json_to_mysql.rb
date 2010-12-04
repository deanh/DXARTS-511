#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => 'dx511',
  :username => 'root',
  :host     => 'localhost'
)

class Download < ActiveRecord::Base
  has_one :location
  has_one :referrer
  def self.create
    ActiveRecord::Schema.define do
      create_table :downloads do |table|
        table.column :artist, :string
        table.column :title, :string
        table.column :source, :string
        table.column :release, :string
        table.column :date, :date
        table.column :time, :string
        table.column :format, :string
        #table.column :referrer_id, :integer
        #table.column :location_id, :integer
      end
    end
  end
end

class Referrer < ActiveRecord::Base
  def self.create
    ActiveRecord::Schema.define do
      create_table :referrers do |table|
        table.column :url, :string
        table.column :host, :string
        table.column :host_ip, :string
        table.column :download_id, :integer
      end
    end
  end
end

class Location < ActiveRecord::Base
  def self.create
    ActiveRecord::Schema.define do
      create_table :locations do |table|
        table.column :lat, :float
        table.column :lng, :float
        table.column :country_code, :string
        table.column :state, :string
        table.column :city, :string
        table.column :download_id, :integer
      end
    end
  end
end

def create_row_from_json(str)
  hsh = JSON.parse(str)
  ref = Referrer.new(hsh['referrer'])
  loc = Location.new(hsh['request_location'])
  ref.save
  loc.save

  hsh['referrer'] = ref
  hsh['location'] = loc
  hsh.delete('request_location') 

  dl = Download.new(hsh)
  dl.save
end


if __FILE__ == $0
  unless infile = ARGV[0] and File.exists? infile
    warn "usage: #{$0} <input file>"
    exit 1
  end

  fh = File.open(infile)
  fh.each do |line|
    next if line =~ /^Host/
    next if line =~ /^\|/
    create_row_from_json(line.chomp)
  end
end

