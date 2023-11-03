class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  def index
    if current_user.spotify_data?
      @followed_artists = Artist.all.with_attached_avatar.order(name: :asc)
    end
  end
end
