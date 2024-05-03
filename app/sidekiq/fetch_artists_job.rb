class FetchArtistsJob
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    FollowedArtistsService.new(user).fetch_and_load_artists
  rescue StandardError => e
    Rails.logger.error "Error fetching followed artists for user #{user_id}: #{e.message}"
  end
end
