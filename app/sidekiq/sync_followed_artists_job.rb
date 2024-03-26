class SyncFollowedArtistsJob
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    SpotifyService.new(user).load_artists
  rescue StandardError => e
    Rails.logger.error "Error syncing followed artists for user #{user_id}: #{e.message}"
  end
end
