# Map is the parent class used by all maps under the module Maps. Methods here are generic to all instances of a map.
# Specific map details (such as overlay methods, and features) are owned by the child classes (ie. Maps::Pct).
#
# A Map consists of waypoints, and overlays formatted for a view. The view is owned by the parent class, as well as the
# waypoints related to the map instance. The overlay options and mechanisms of retrieval are map type specific and are
# thus handled there, yet methods for normalizing and aggregating these overlays are maintained in this class.
# This allows for the easy integration of new map types without downstream consequence.
#
# Typical usage is through a subclass as they contain most of the interesting details for the view.
#
#   map = Maps::Pct.new(waypoints).as_view(
#     overlays: %i[mile_markers waypoints],
#     zoom: 5
#   )
class Map
  attr_accessor :center, :bounds, :zoom, :waypoints

  # @param waypoints The waypoints to associate with the map. If provided, used when building overlays.
  def initialize(waypoints = nil)
    @waypoints = waypoints if waypoints.present? # if empty remain nil
  end

  # The coordinates of the last waypoint registered to the Map.
  def current_coord
    return nil unless @waypoints

    [@waypoints.last.latitude, @waypoints.last.longitude]
  end

  # Return the map formatted for the client
  # @param overlays: Optional Array of overlay methods. Module dependent. Check the instance of map for options.
  # @param center: Optional custom center [latitude, longitude]
  # @param bounds: Optional custom boundary [[top_left_latitude, top_left_longitude], [bottom_right_latitude, bottom_right_longitude]]
  # @param zoom: Optional custom zoom level.
  def as_view(overlays: nil, center: current_coord, bounds: nil, zoom: 20)
    {
      overlays: (overlays&.map { |o| format_overlay(o) }).reject(&:nil?),
      center: center || [0, 0],
      bounds: bounds.is_a?(Array) ? bounds : nil, # TODO: Probably should validate bounds here
      zoom: zoom
    }
  end

  # Format an overlay option for viewing. An overlay option is a method in a Maps instance that returns an
  # object containing a name, type, and items. Items are of type markers, or geoJson.
  def format_overlay(olay)
    olay = "#{olay.to_s}_overlay"
    return unless respond_to?(olay)

    res = public_send(olay)
    { name: res[:name], type: res[:type], items: res[:items].is_a?(Array) ? res[:items] : [res[:items]] }
  end

  # Absolute distance between two points
  # @param start
  # @param finish
  # @return absolute distance.
  def self.travel_distance(start, finish)
    return unless start.present? && finish.present?

    (start - finish).abs
  end

  # Calculate the rate of travel between two points given the start and finish times and distance between.
  # @param time_start:
  # @param time_finish:
  # @param distance
  # @return {mph: Float, minutes_per_mile: Float, total_minutes: Float}
  def self.travel_rate(time_start, time_finish, distance)
    return unless time_start.present? && time_finish.present? && distance.present?

    time_diff = time_finish.to_f - time_start.to_f

    mph = distance / (time_diff / 3600)
    minutes_per_mile = 60 / mph
    total_minutes = time_diff / 60
    { mph: mph, minutes_per_mile: minutes_per_mile, total_minutes: total_minutes }
  end

  # Helper method to get travel_rate and travel_distance in one call.
  def self.travel_details(mile_start, mile_finish, time_start, time_finish)
    distance = travel_distance(mile_start, mile_finish)
    rate = travel_rate(time_start, time_finish, distance)
    { mile: mile_finish, prev_mile: mile_start, distance: distance, rate: rate }
  end

  # @param points: An array containing lat, lng points (or other x,y) - (ie: Map.mile_markers)
  # @param waypoint: A particular waypoint to search against @points for
  # @param get_lat: a proc for retrieving the x point from waypoint (defaults to points.latitude) - (ie: ->(p) { p[:longitude] } )
  # @param get_lng: a proc for retrieving the y point from waypoint (defaults to points.longitude)
  def self.nearest_point(points, waypoint, get_lat = ->(p) { p.latitude }, get_lng = ->(p) { p.longitude })
    # Memoization of the tree improves run time speed from over a minute to milliseconds
    @tree ||= kd_tree(points)
    @tree.nearest([get_lat.call(waypoint), get_lng.call(waypoint)])

    # OPTIONAL: nearests within range using miles relative geo distance in miles
    # @tree.nearest_geo_range([47.6, -122.3], 2).first
  end

  # Convert a lng,lat,elv coordinate to cartesian (radian) using the Spherical law of cosines.
  # @param latitude
  # @param longitude
  # @param elevation from sea level.
  def self.point_to_cartesian(latitude, longitude, elevation = 0.0)
    # Convert to radians
    latitude *= (Math::PI / 180)
    longitude *= (Math::PI / 180)

    r = 6_378_137.0 + elevation # 6371km + Elevation from sea level = geographic point relative to the centre of earth.
    x = r * Math.cos(latitude) * Math.cos(longitude)
    y = r * Math.cos(latitude) * Math.sin(longitude)
    z = r * Math.sin(latitude)
    [x, y, z]
  end

  # The great circle difference between two coordinates
  # Currently less accurate on land given elevation.
  # TODO: Should be integrated with point_to_cartesian
  # Broken down to single steps for readability
  # https://en.wikipedia.org/wiki/Great-circle_distance
  # http://edwilliams.org/avform147.htm#Dist
  def self.great_circle_distance(lat1, lng1, lat2, lng2)
    pow = lambda { |a, b|
      power = 1
      (1..b).each { power *= a }
    }
    Math.asin(
      Math.sqrt(
        Math.cos(lat1) *
          Math.cos(lat2) *
          pow.call(Math.sin((lng1 - lng2) / 2), 2) +
          pow.call(Math.sin((lat1 - lat2) / 2), 2)
      )
    ) * 2
  end

  private

  # Build a kd tree for efficient point pair search.
  def self.kd_tree(points, get_lat = ->(p) { p[:lat] }, get_lng = ->(p) { p[:lng] })
    tree = Geokdtree::Tree.new(2)
    points.each do |p|
      tree.insert([get_lat.call(p), get_lng.call(p)], p[:properties])
    end
    tree
  end

  # Convert geoJson object into a Marker
  def self.as_markers(geo)
    geo['features'].map do |g|
      marker(
        g['geometry']['coordinates'][1],
        g['geometry']['coordinates'][0],
        g['properties'].transform_keys { |k| k.downcase.to_sym }
      )
    end
  end

  # Convert a collection of Markers into a single geoJson line
  def self.markers_to_geojson_line(markers)
    {
      "type": 'LineString',
      "coordinates": markers.map { |m| [m[:lat], m[:lng]] }
    }
  end

  # Generate a Marker object
  def self.marker(lat, lng, properties = nil)
    raise "Invalid param value: latitude #{lat}" unless lat.is_a? Float
    raise "Invalid param value: latitude #{lng}" unless lng.is_a? Float

    {
      lat: lat,
      lng: lng,
      properties: properties
    }
  end
end