class WaypointsController < ApplicationController
  def index
    @waypoints = Waypoint.all_with_cache
    respond_to do |format|
      if @waypoints
        format.json { render json: @waypoints, status: :ok }
      else
        format.json { render json: { error: 'Error retrieving locations' }, status: :internal_server_error }
      end
    end
  end

end
