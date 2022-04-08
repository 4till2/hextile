module Services
  class GarminParser
    BASE_URL = 'https://share.garmin.com'.freeze

    def initialize(user_id = ENV['GARMIN_USERNAME'])
      @user_id = user_id
    end

    def waypoints
      res = HTTParty.get("#{BASE_URL}/#{@user_id}/Waypoints")
      waypoints = res.first.second # just the path to the waypoints. More robust solution required to prevent failure on uncontrolled changes
      waypoints.map do |entry|
        {
          title: entry['X'].to_s,
          latitude: entry['L'].to_f,
          longitude: entry['N'].to_f,
          elevation: entry['E'].to_f,
          external_created_at: entry['C'].to_datetime,
          external_updated_at: entry['C'].to_datetime,
          external_id: entry['D'].to_i,
          external_name: 'garmin'
        }
      end
    end
  end
end
