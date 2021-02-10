require 'pry'
require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'couchrest'

DB = CouchRest.new.database('realtor_search')

class FindDeals
  attr_accessor :list, :search_props

  def initialize(city)
    @list = Hash.new
    @search_props = {
      city: city,
      state_code: 'NV',
      offset: 0,
      limit: 10,
      price_max: 600000,
      baths_min: 2,
      property_type: 'single_family',
      homehome_size_min: 1250
    }
  end

  def api_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri)
    request["x-rapidapi-key"] = ENV["RAPID_KEY"]
    request["x-rapidapi-host"] = 'realtor-com-real-estate.p.rapidapi.com'
    http.request(request)
  end

  def search
    uri = URI("https://realtor-com-real-estate.p.rapidapi.com/for-sale")
    uri.query = URI.encode_www_form(@search_props)
    response = api_request(uri)

    if r = JSON.parse(response.read_body)
      r['data']['results'].each do |listing|
        props = listing.select {|k, |[:property_id, :last_update_date, :list_price, :description, :tags, :primary_photo].include? k.to_sym}
        props['_id'] = props['property_id']
        begin
          DB.save_doc(props)
        rescue CouchRest::Conflict
          DB.update_doc(props['_id']){props}
        end
      end
    end
  end

  def home_estimate_value(property_id)
    uri = URI("https://realtor-com-real-estate.p.rapidapi.com/for-sale/home-estimate-value")
    search_hash = {
      property_id: property_id
    }
    uri.query = URI.encode_www_form(search_hash)
    response = api_request(uri)

    if r = JSON.parse(response.read_body)
      return r['data']['current_values'] rescue nil
    end
  end

  def load_home_estimates
    DB.view('homes/ids')['rows'].each do |row|
      if v = home_estimate_value(row['id'])
        doc = DB.get(row['id'])
        doc['current_values'] = v
        doc.save
      end
    end
  end
end

find_deals = FindDeals.new("Carson City")
find_deals.search
find_deals.load_home_estimates
