class Hostip < ActiveRecord::Base
  # loc_hash = { 
  #   :lat => loc.lat,
  #   :lng => loc.lng,
  #   :country_code => loc.country_code,
  #   :state        => loc.state,
  #   :city         => loc.city,
  # }

  def self.geocode(ip)
    a,b,c,d = ip.split(".")
    self.set_table_name "hostip.ip4_#{a}"
    ip = find(:first, :select => "lat,lng,countries.code,
                                  cityByCountry.name,cityByCountry.state",
              :joins => %Q{LEFT JOIN hostip.cityByCountry
                               ON hostip.ip4_#{a}.city = hostip.cityByCountry.city
                               AND hostip.ip4_#{a}.country = 
                                   hostip.cityByCountry.country
                            LEFT JOIN hostip.countries
                               ON hostip.countries.id = 
                                   hostip.ip4_#{a}.country},
              :conditions => ["b = ? and c = ?", b,c])
    if ip
      { :lat => ip.lat, :lng => ip.lng, 
        :country_code => ip.code, :state => ip.state,
        :city => ip.name ? ip.name.split('%2C')[0] : nil }
    else
      { :lat => nil, :lng => nil, 
        :country_code => nil, :state => nil,
        :city => nil }     
    end
  end
end 
