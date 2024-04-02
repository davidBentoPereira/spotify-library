module Spotify
  class FollowedArtistsController < ApplicationController
    def index
      if current_user&.spotify_data?
        @followed_artists_count = current_user.artists.count
        @page = params[:page] || 1
        @tags = current_user.tags
        @followed_artists = current_user.artists.joins(:followed_artists).order(name: :asc).page(params[:page])
      end
    end

    def show
      @followed_artist = FollowedArtist.find(params[:id])
    end

    def edit
      @followed_artist = FollowedArtist.find_by(artist_id: params[:id])
      @selected_tags = @followed_artist.tag_list
    end

    def create
      #
      SpotifyService.new(current_user).fetch_and_load_artists

      head :ok
    end


    # Only allow to edit the tags on a followed_artist
    def update
      @followed_artist = FollowedArtist.find(params[:id])

      if @followed_artist.update!(tag_list: params[:followed_artist][:tag_list].join(", ").strip)
        redirect_to spotify_followed_artists_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def followed_artist_params
      params.require(:followed_artist).permit(:tag_list)
    end
  end
end