POS_OFFSET = 0.003
MILES_PER_DAY = 16
MINUTES_PER_MILE = 16
MILE_MARKERS = Maps::Pct.new._mile_markers
TOTAL_WAYPOINTS = 1000
DATE = DateTime.now - 8.weeks
@time_offset = 0

# The current date + 12 minutes per mile + days for 
def date(index)
  @time_offset += 1.day if (index % MILES_PER_DAY).zero? # add a day to time offset
  @time_offset += MINUTES_PER_MILE.minutes # add minutes traveled
  DATE + @time_offset
end

# Create a waypoint at x mile markers at a rate of 12 minutes per mile
(1..TOTAL_WAYPOINTS).each do |i|
  Waypoint.create!(title: "SEED-MILE-#{MILE_MARKERS[i * 2][:properties][:mile]}",
                   longitude: (MILE_MARKERS[i * 2][:lng] - POS_OFFSET),
                   latitude: (MILE_MARKERS[i * 2][:lat] + POS_OFFSET),
                   external_created_at: date(i))
end
