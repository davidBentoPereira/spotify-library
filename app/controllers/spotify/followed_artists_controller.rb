module Spotify
  class FollowedArtistsController < ApplicationController
    def index
      return unless current_user&.spotify_data?

      @tags = current_user.tags
      @page = followed_artist_params[:page].to_i || 1
      @limit = followed_artist_params[:limit] || 16
      followed_artists_query = current_user.followed_artists.includes(:artist)

      @followed_artists =
        if params[:filter].present?
          followed_artists_query.tagged_with(followed_artist_params[:filter]).order("artists.name ASC").page(@page).per(@limit)
        else
          followed_artists_query.order("artists.name ASC").page(@page).per(@limit)
        end

      @total_count = @followed_artists.total_count.to_i
      @total_pages = @followed_artists.total_pages.to_i
    end

    # Only allow to edit the tags on a followed_artist
    def edit
      @followed_artist = FollowedArtist.find_by(artist_id: params[:id], user_id: current_user.id)
      @selected_tags = @followed_artist.tags
    end

    # Only allow to fetch the followed artists from Spotify
    def create
      SpotifyService.new(current_user).fetch_and_load_artists

      head :ok
    end


    # Only allow to update the tags on a followed_artist
    def update
      @followed_artist = FollowedArtist.find(params[:id])
      tags = params[:followed_artist][:tag_list].reject(&:blank?).join(", ").strip

      if current_user.tag(@followed_artist, :with => tags, :on => :tags)
        redirect_to spotify_followed_artists_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def followed_artist_params
      params.permit(:tag_list, :page, :limit, :filter)
    end
  end
end