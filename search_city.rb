require 'uri'
require 'net/http'
require 'openssl'

uri = URI("https://realtor-com-real-estate.p.rapidapi.com/for-sale")
search_hash = {
  city: "Carson City",
  state_code: 'NV',
  offset: 0,
  limit: 5,
  price_max: 600000,
  baths_min: 2,
  property_type: 'single_family',
  homehome_size_min: 1250
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
