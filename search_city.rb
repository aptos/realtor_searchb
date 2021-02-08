require 'uri'
require 'net/http'
require 'openssl'

url = URI("https://realtor-com-real-estate.p.rapidapi.com/for-sale?city=Carson%20CIty&state_code=Nevada&offset=0&limit=42&price_max=600000&baths_min=2&property_type=single_family&home_size_min=1250")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["x-rapidapi-key"] = ENV["RAPID_KEY"]
request["x-rapidapi-host"] = 'realtor-com-real-estate.p.rapidapi.com'

response = http.request(request)
puts response.read_body
