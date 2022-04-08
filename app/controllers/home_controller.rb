class HomeController < ApplicationController
  def index
    offset = params[:offset] || 0
    limit = params[:limit] || 1000
    @timeline = Timeline.new

    @days = @timeline.days.reverse[offset.to_i, limit.to_i]
    @details = @timeline.map.average_details
    # todo: Look into using stale?
  end

  def test; end
end
