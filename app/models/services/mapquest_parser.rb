module Services
  class MapquestParser
    BASE_URL = 'http://www.mapquestapi.com'.freeze
    KEY = ENV['MAPQUEST_KEY'].freeze

    attr_accessor :waypoints

    def initialize
      @coordinates = []
    end

    def add_coordinates(cords)
      cords.each { |l| @coordinates.push("#{l[0]},#{l[1]}") }
    end

    def fetch_geocodes
      @fetch_geocodes ||= unless @coordinates.empty?
                            HTTParty.get("#{BASE_URL}/geocoding/v1/batch?key=#{KEY}#{@coordinates.map { |l| "&location=#{l}" }.join()}&includeRoadMetadata=true&includeNearestIntersection=true")
                          end
    end

    def geocodes
      fetch_geocodes['results']
    end

    def geocodes_by_cords(lat, lng)
      res = geocodes&.detect do |r|
        given = r['providedLocation']['latLng']
        given['lat'] == lat && given['lng'] == lng
      end
      return unless res

      el = res['locations'][0]
      Hashie::Mash.new({
                         street: el['street'].to_s,
                         neighborhood: el['adminArea6'].to_s,
                         city: el['adminArea5'].to_s,
                         county: el['adminArea4'].to_s,
                         state: el['adminArea3'].to_s,
                         country: el['adminArea1'].to_s,
                         postal_code: el['postalCode'].to_s,
                         calculated_latitude: el['latLng']['lat'].to_f,
                         calculated_longitude: el['latLng']['lng'].to_f
                       })
    end
  end
end
