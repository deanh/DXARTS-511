module DownloadHelper
  def get_referrer_ip(ref)
    return if ref == nil
    
    # strip protocol and query string
    if md = ref.match(/http:\/\/([^\/?]*).*/)
      ref = md[1]
    end
    #ref.sub!(/http:\/\/([^\/?]*).*/, $1) if ref =~ /^http:/
    # IP lookup. q & d
    
    return case
           when ref == nil                   : nil
           when ref == ''                    : nil
           when ref =~ /^\s+$/               : nil
           when ref =~ /^\d+\.\d+\.\d+\.\d+$/: ref
           else
             begin
               `host #{ref}`.match(/\d+\.\d+\.\d+\.\d+/)[0]
             rescue
             end 
           end
  end
  
  def loc_to_hash(loc)
    loc_hash = { 
      :lat => loc.lat,
      :lng => loc.lng,
      :country_code => loc.country_code,
      :state        => loc.state,
      :city         => loc.city,
      :zip          => loc.zip
    }
  end
end
