module DownloadHelper

  module S3
    # regex to parse loggiles and store apropriate data
    def self.RE
      %r{
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
    end

    def self.format_date(str)
      month_map = {
        "Apr" => "04", "Aug" => "08", "Dec" => "12",
        "Feb" => "02", "Jan" => "01", "Jul" => "07",
        "Jun" => "06", "Mar" => "03", "May" => "05",
        "Nov" => "11", "Oct" => "10", "Sep" => "09"
      }
      match = str.match(/(\d{2})\/(\w{3})\/(\d{4}):([0-9:]+)/)
      return "#{match[3]}-#{month_map[match[2]]}-#{match[1]}", match[4]
    end
  end

  def referrer_host(ref)
    match = ref.match(%r{(\w+://)?([^/]+)})
    match[0]
  end

  def get_referrer_ip(ref)
    return if ref == nil
    
    # strip protocol and query string
    if md = ref.match(/http:\/\/([^\/?]*).*/)
      ref = md[1]
    end

    # IP lookup. q & d
    
    return case
           when ref == nil                   : nil
           when ref == ''                    : nil
           when ref =~ /^\s+$/               : nil
           when ref =~ /^\s*-\s*$/           : nil
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
