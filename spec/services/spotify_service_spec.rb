require "rails_helper"

RSpec.describe SpotifyService do
  let(:current_user) { create(:user, :with_spotify_data) }
  let(:spotify_user) { current_user.spotify_user }

  subject(:spotify_service) { described_class.new(spotify_user) }

  describe "public methods" do
    describe "#new" do
      it "initializes spotify_user" do
        expect(spotify_service.spotify_user).to eq(spotify_user)
      end
    end

    describe "#total_followed_artists" do
      let(:spotify_user) { instance_double(RSpotify::User) }

      before { allow(current_user).to receive(:spotify_user).and_return(spotify_user) }

      context 'when the Spotify API returns a valid response' do
        let(:response_body) { { "artists" => { "total" => 10 } }.to_json }

        before { allow(spotify_user).to receive(:following).with(type: 'artist').and_return(response_body) }

        it 'returns the total number of followed artists' do
          expect(spotify_service.total_followed_artists).to eq(10)
        end
      end

      context 'when the Spotify API returns an error response' do
        before { allow(spotify_user).to receive(:following).with(type: 'artist').and_raise(RestClient::ExceptionWithResponse) }

        it 'logs an error message and returns nil' do
          expect(Rails.logger).to receive(:error).with(/Unexpected error when fetching total followed artists from Spotify/)
          expect(spotify_service.total_followed_artists).to be_nil
        end
      end
    end

    describe "#fetch_artists" do
      let(:total_followed_artists) { 50 }
      let(:artists_per_batch) { 10 }

      before do
        allow(spotify_service).to receive(:fetch_batch_of_artists) do |last_artist_id|
          # Create a batch of fake artists for the test
          if last_artist_id.nil?
            (1..artists_per_batch).map { |i| Artist.new(id: i, name: "Artist #{i}") }
          else
            last_id = last_artist_id.to_i
            next_id = last_id + artists_per_batch
            (last_id + 1..next_id).map { |i| Artist.new(id: i, name: "Artist #{i}") }
          end
        end
      end

      it "fetch all followed artists from Spotify" do
        fetched_artists = spotify_service.send(:fetch_artists)

        expect(fetched_artists.size).to eq(total_followed_artists)
      end
    end
  end

  describe "private methods" do
    describe '#fetch_batch_of_artists' do
      let(:last_artist_id) { '123456' }
      let(:args) { { type: 'artist', limit: described_class::SPOTIFY_MAX_LIMIT_PER_PAGE, after: last_artist_id } }

      subject(:fetch_batch_of_artists) { spotify_service.send(:fetch_batch_of_artists, last_artist_id) }

      context 'when the Spotify API call is successful' do
        let(:artists) { [double('Artist')] }

        before { allow(current_user).to receive_message_chain(:spotify_user, :following).with(args).and_return(artists) }

        it 'returns an array of artists' do
          expect(fetch_batch_of_artists).to eq(artists)
        end
      end

      context 'when the Spotify API call fails' do
        let(:last_artist_id) { '123456' }
        let(:error) { RestClient::ExceptionWithResponse.new('Unauthorized', 401) }

        before { allow(current_user).to receive_message_chain(:spotify_user, :following).with(args).and_raise(error) }

        it 'returns nil' do
          expect(fetch_batch_of_artists).to be_nil
        end

        it 'logs an error' do
          expect(Rails.logger).to receive(:error).with(/Error fetching batch of artists from Spotify:/)
          fetch_batch_of_artists
        end
      end
    end
  end
end