class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  def index
    if current_user&.spotify_data?
      @followed_artists_count = current_user.artists.count
      @page = params[:page] || 1
      @followed_artists = current_user.artists.with_attached_avatar.order(name: :asc).page(params[:page])
    end
  end
end