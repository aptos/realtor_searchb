require 'uri'
require 'net/http'
require 'openssl'

uri = URI("https://realtor-com-real-estate.p.rapidapi.com/for-sale/home-estimate-value")
search_hash = {
  property_id: 2061530895
}
uri.query = URI.encode_www_form(search_hash)

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(uri)
request["x-rapidapi-key"] = ENV["RAPID_KEY"]
request["x-rapidapi-host"] = 'realtor-com-real-estate.p.rapidapi.com'

response = http.request(request)
puts response.read_body