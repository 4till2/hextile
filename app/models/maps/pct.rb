module Maps
  # The Pacific Crest Trail map
  # *Possible* *@overlays*
  # - waypoints
  # - mile_markers
  # - center_line
  # - permit_areas
  # - town_resupply
  FALLBACK_START_DATE = '01/05/2022'.freeze
  FALLBACK_MINUTES_PER_MILE = 25

  class Pct < Map

    def initialize(waypoints = nil)
      super
    end

    def waypoint_mile(waypoint)
      Map.nearest_point(_mile_markers, waypoint)&.data[:mile] || 0
    end

    # Associates each waypoint with the nearest mile marker.
    # Calculates the distance from the last waypoint with a mile
    def waypoints_overlay
      @waypoints_overlay ||= begin
                               data = []
                               @waypoints&.each_with_index do |wp, i|
                                 mile = waypoint_mile(wp)
                                 time = wp[:external_created_at]
                                 marker_prev = previous_marker(data, mile, i)
                                 mile_prev = marker_prev ? marker_prev[:properties][:mile] : 0
                                 time_prev = marker_prev[:properties][:arrival] if marker_prev
                                 details = Map.travel_details(mile_prev, mile, time_prev, time)
                                 marker = Map.marker(wp.latitude, wp.longitude,
                                                     { **details,
                                                       arrival: wp[:external_created_at],
                                                       tooltip: mile_tooltip_html(mile, wp[:external_created_at]),
                                                       className: 'map-marker waypoint' })
                                 data.push(marker)
                               end
                               { name: 'Waypoints', type: 'Marker', items: data }
                             end
    end

    def mile_markers_overlay
      @mile_markers_overlay ||= begin
                                  data = []
                                  _mile_markers.each_with_index do |m, i|
                                    m[:properties][:arrival] = approximate_arrival(m[:properties][:mile])
                                    m[:properties][:tooltip] =
                                      mile_tooltip_html(m[:properties][:mile], m[:properties][:arrival])
                                    m[:properties][:className] = "map-marker #{past?(m[:properties][:arrival]) ? 'visited' : 'unvisited'}"
                                    data.push(m)
                                  end
                                  current_mile = data.reverse.find { |i| i[:properties][:className].match(/ visited/) }
                                  current_mile[:properties][:className] += ' current-mile' if current_mile
                                  { name: 'Mile Markers', type: 'Marker', items: data }
                                end
    end

    def center_line_overlay
      @center_line_overlay ||= begin
                                 data = _center_line
                                 { name: 'Center Line', type: 'GeoJson', items: data }
                               end
    end

    def permit_areas_overlay
      @permit_areas_overlay ||= begin
                                  data = _permit_areas
                                  { name: 'Permit Area', type: 'GeoJson', items: data }
                                end
    end

    def town_resupply_overlay
      @town_resupply_overlay ||= begin
                                   data = _town_resupply
                                   { name: 'Town Resupply', type: 'GeoJson', items: data }
                                 end
    end

    # The travel details for the entire trip. Provides the average rate and total distance traveled
    def average_details
      @average_details ||= begin
                             return unless @waypoints.present? && @waypoints.count >= 2

                             wp_first = @waypoints.first
                             wp_last = @waypoints.last
                             mile_first = Map.nearest_point(_mile_markers, wp_first)&.data[:mile]
                             mile_last = Map.nearest_point(_mile_markers, wp_last)&.data[:mile]
                             Map.travel_details(mile_first, mile_last, wp_first.external_created_at,
                                                wp_last.external_created_at)
                           end
    end

    # The waypoint nearest to a given mile
    def nearest_waypoint(mile)
      points = waypoints_overlay[:items]
      points.each do |wp|
        wp_mile = wp[:properties][:mile]
        next if wp_mile < mile

        return wp if wp_mile == mile

        if wp_mile > mile
          # Predict past arrival by the distance between the mile marker and the next waypoint * rate at that waypoint.
          return wp
        end
      end
      points.last
    end

    # The approximated time of arrival to a specified mile. Calculated based using the nearest waypoints or average rate.
    def approximate_arrival(mile)
      points = waypoints_overlay[:items]
      points.each do |wp|
        wp_mile = wp[:properties][:mile]
        next if wp_mile < mile

        return wp[:properties][:arrival] if wp_mile == mile

        if wp_mile > mile && wp[:properties][:arrival] && wp[:properties][:rate]
          # Predict past arrival by the distance between the mile marker and the next waypoint * rate at that waypoint.
          return wp[:properties][:arrival] - ((wp_mile - mile) * wp[:properties][:rate][:minutes_per_mile]).minutes
        end
      end
      # Predict future arrival by distance between the mile marker and most recent waypoint * average rate
      rate = average_details ? average_details[:rate][:minutes_per_mile] : FALLBACK_MINUTES_PER_MILE
      prev_mile = points.last.present? ? points.last[:properties][:mile] : 0
      prev_arrival = points.last.present? ? points.last[:properties][:arrival] : Date.parse(FALLBACK_START_DATE)
      prev_arrival + ((mile - prev_mile) * rate).minutes
    end

    def _mile_markers
      markers = []
      Map.as_markers(
        Rails.cache.fetch(:arcgis_mile_markers, expires_in: 1.year) { Services::ArcgisParser.new.mile_markers }
      ).each_with_index { |m, i| markers.push(m) if i.odd? } # Filter every full mile
      markers
    end

    def _center_line
      Rails.cache.fetch(:arcgis_center_line, expires_in: 1.year) { Services::ArcgisParser.new.center_line }
    end

    def _town_resupply
      Rails.cache.fetch(:arcgis_town_resupply, expires_in: 1.year) { Services::ArcgisParser.new.town_resupply }
    end

    def _permit_areas
      Rails.cache.fetch(:arcgis_permit_areas, expires_in: 1.year) { Services::ArcgisParser.new.permit_areas }
    end

    private

    # Finds the last marker before current to have a different mile
    def previous_marker(markers, current_mile, current_index)
      current_index -= 1
      while markers[current_index].present? && (markers[current_index][:properties][:mile] == current_mile ||
        markers[current_index][:properties][:mile].nil?)
        current_index -= 1
      end
      markers[current_index]
    end

    def mile_tooltip_html(mile, arrival)
      "
<div>
<h3>Mile</h3>
<p class='font-bold text-xl'>#{mile}</p>
<h3 class='border-t border-dashed'> Approximate Arrival </h3>
<p class='font-bold'><span class='text-xl'>#{time_in_words(arrival)}</p>
<p class = 'text-gray-500'> #{arrival.strftime('%a %d %b %Y')}</p>
</div>
"
    end

    def time_in_words(date)
      "#{ActionController::Base.helpers.distance_of_time_in_words_to_now(date.to_s)} #{past?(date) ? ' ago ' : ' from now '}"
    end

    def past?(date)
      to = date.to_datetime
      from = DateTime.now
      to < from
    end

  end
end
