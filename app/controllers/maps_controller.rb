class MapsController < ApplicationController

  def json
    map = Timeline.new.map_view
    respond_to do |format|
      if map
        format.json { render json: map, status: :ok }
      else
        format.json { render json: { error: 'Error retrieving locations' }, status: :internal_server_error }
      end
    end
  end

  def index; end
end
