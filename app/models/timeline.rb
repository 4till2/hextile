class Timeline
  include DateConcern

  # Generates a timeline of the available resources within an optional range. Defaults to all dates
  # @param from: start date (optional)
  # @param to: end date (optional)
  def initialize(from: nil, to: nil)
    @from = from
    @to = to
  end

  def media
    @media ||= Media.by_dates(from: @from, to: @to)
  end

  def posts
    @posts ||= Post.by_dates(from: @from, to: @to)
  end

  def waypoints
    @waypoints ||= Waypoint.by_dates(from: @from, to: @to)
  end

  def map
    @map ||=
      Maps::Pct.new(waypoints)
  end

  def map_view
    @map_view ||= map.as_view(
      overlays: %i[mile_markers waypoints], # TODO: investigate why adding center_line pushes the servers memory past the limit. 110mb to 900mb!
      zoom: 10,
      center: waypoints.present? ? [waypoints.last.latitude, waypoints.last.longitude] : [32.5958334060001, -116.46669636] # defaylt is pct-campo
    )
  end

  # @return The available content grouped by date {date: Date, media : [Media], posts: [Post], waypoints: [Waypoint]}
  def days
    m = media&.group_by { |item| item.external_created_at.to_date } || {}
    p = posts&.group_by { |item| item.external_created_at.to_date } || {}
    w = waypoints&.group_by { |item| item.external_created_at.to_date } || {}
    days = (m.keys + p.keys + w.keys).uniq.map do |key|
      { date: key, media: m[key], posts: p[key], waypoints: w[key], distance: average_travel_details(w[key]) }
    end
    days.sort_by { |d| d[:date] }
  end

  def average_travel_details(waypoints)
    return unless waypoints.present?

    start = waypoints[0]
    finish = waypoints[-1]
    # Map.travel_details(map.waypoint_mile(start), map.waypoint_mile(finish), start.external_created_at, finish.external_created_at)
    Map.travel_distance(map.waypoint_mile(start), map.waypoint_mile(finish))
  end

  def self.all
    Timeline.new.days
  end

end
