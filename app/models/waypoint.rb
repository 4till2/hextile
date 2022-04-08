# (mile current - mile last / current external_created_at  - external_created_at last) can be used to determine speed
class Waypoint < ApplicationRecord
  include Sanitizer
  include DateConcern
  scope :timeline, -> { order(external_created_at: :desc) }
  validates_presence_of :external_created_at
  before_save { self.external_created_at = external_created_at.utc }

  def self.refresh(clean: false)
    destroy_all if clean # for removing stale waypoints
    existing_external_ids = all.pluck(:external_id) # only those waypoints that are new
    # Only create waypoints not yet in system, unless refresh_all is true
    waypoints = Services::GarminParser.new.waypoints.reject { |w| existing_external_ids.include? w[:external_id] }
    mq = Services::MapquestParser.new
    # By first adding all coordinates to mapquester service we can safely make one batch request instead of one per waypoint
    mq.add_coordinates(waypoints.pluck(:latitude, :longitude))
    # We then create each waypoint with the geo results matching the provided coordinates
    waypoints.each do |waypoint|
      geocode = mq.geocodes_by_cords(waypoint[:latitude], waypoint[:longitude])
      create({ **sanitize_params(waypoint), geocode: geocode })
    end
  end

  def self.all_with_cache
    ids = Rails.cache.fetch(:waypoints, expires_in: 2.minutes) do
      Waypoint.refresh
      Waypoint.pluck(:id)
    end
    Waypoint.where(id: ids).to_a
  end

end
