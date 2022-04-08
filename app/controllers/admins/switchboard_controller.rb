class Admins::SwitchboardController < ApplicationController
  before_action :authenticate_admin!, except: :login

  def login
    redirect_to "#{root_path}admins/auth/google_oauth2", _allow_other_host: true
  end

  def reset_all
    _cache_reset
    _waypoint_reset
    redirect_to root_path, notice: 'Reset All'
  end

  def reset_cache
    _cache_reset
    redirect_to root_path, notice: 'Cache reset'
  end

  def reset_waypoints
    _waypoint_reset
    redirect_to root_path, notice: 'Waypoints reset'
  end

  private

  def _cache_reset
    Rails.cache.clear
  end

  def _waypoint_reset
    Waypoint.refresh(clean: true)
  end

  def is_admin?
    current_admin.present? && current_admin == Admin.find(email: ENV['ADMIN_EMAIL'])
  end
end