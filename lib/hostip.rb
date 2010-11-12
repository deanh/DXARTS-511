class Hostip < ActiveRecord::Base

  def self.geocode(ip)
    a,b,c,d = ip.split(".")
    self.set_table_name "hostip.ip4_#{a}"

    geo_lookup = find(
        :first,
        :select => "lat,lng,countries.code,cityByCountry.name,cityByCountry.state",
        :joins  => %Q{
            LEFT JOIN hostip.cityByCountry
              ON hostip.ip4_#{a}.city = hostip.cityByCountry.city
                AND hostip.ip4_#{a}.country = hostip.cityByCountry.country
            LEFT JOIN hostip.countries
              ON hostip.countries.id = hostip.ip4_#{a}.country
        },
        :conditions => ["b = ? and c = ?", b,c]
    )

    if geo_lookup
      return { 
        :lat => geo_lookup.lat, :lng => geo_lookup.lng, 
        :country_code => geo_lookup.code, :state => geo_lookup.state,
        :city => geo_lookup.name ? geo_lookup.name.split('%2C')[0] : nil
      }
    else
      puts "Host IP lookup fail for: #{ip}" 
      return { 
        :lat => nil, :lng => nil, 
        :country_code => nil, :state => nil,
        :city => nil
      }     
    end
  end
end 
