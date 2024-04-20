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

    describe "#fetch_all_followed_artists" do
      let(:artist1) { double('Artist', id: '123') }
      let(:artist2) { double('Artist', id: '456') }
      let(:artist3) { double('Artist', id: '789') }
      let(:fetched_artists_batch1) { [artist1, artist2] }
      let(:fetched_artists_batch2) { [artist3] }
      let(:fetched_artists_batch3) { [] }

      before do
        allow(spotify_service).to receive(:total_followed_artists).and_return(3)
        allow(spotify_service).to receive(:fetch_batch_of_followed_artists).with(nil).and_return(fetched_artists_batch1)
        allow(spotify_service).to receive(:fetch_batch_of_followed_artists).with('456').and_return(fetched_artists_batch2)
        allow(spotify_service).to receive(:fetch_batch_of_followed_artists).with('789').and_return(fetched_artists_batch3)
      end

      it 'fetches all followed artists from Spotify' do
        expect(spotify_service.fetch_all_followed_artists).to eq([artist1, artist2, artist3])
      end

      it 'calls fetch_batch_of_followed_artists with correct arguments' do
        expect(spotify_service).to receive(:fetch_batch_of_followed_artists).with(nil)
        expect(spotify_service).to receive(:fetch_batch_of_followed_artists).with('456')
        expect(spotify_service).not_to receive(:fetch_batch_of_followed_artists).with('789')
        spotify_service.fetch_all_followed_artists
      end

      it 'stops fetching if total number of fetched artists reaches or exceeds total number of followed artists' do
        allow(spotify_service).to receive(:total_followed_artists).and_return(1)
        expect(spotify_service).to receive(:fetch_batch_of_followed_artists).with(nil).and_return(fetched_artists_batch1)
        expect(spotify_service).not_to receive(:fetch_batch_of_followed_artists).with('456')
        expect(spotify_service).not_to receive(:fetch_batch_of_followed_artists).with('789')
        spotify_service.fetch_all_followed_artists
      end

      it 'stops fetching if maximum loop count is exceeded' do
        stub_const("SpotifyService::MAX_LOOP", -1)
        expect(spotify_service).to receive(:fetch_batch_of_followed_artists).once
        spotify_service.fetch_all_followed_artists
      end
    end
  end

  describe "private methods" do
    describe '#fetch_batch_of_followed_artists' do
      let(:last_artist_id) { '123456' }
      let(:args) { { type: 'artist', limit: described_class::SPOTIFY_MAX_LIMIT_PER_PAGE, after: last_artist_id } }

      subject(:fetch_batch_of_followed_artists) { spotify_service.send(:fetch_batch_of_followed_artists, last_artist_id) }

      context 'when the Spotify API call is successful' do
        let(:artists) { [double('Artist')] }

        before { allow(current_user).to receive_message_chain(:spotify_user, :following).with(args).and_return(artists) }

        it 'returns an array of artists' do
          expect(fetch_batch_of_followed_artists).to eq(artists)
        end
      end

      context 'when the Spotify API call fails' do
        let(:last_artist_id) { '123456' }
        let(:error) { RestClient::ExceptionWithResponse.new('Unauthorized', 401) }

        before { allow(current_user).to receive_message_chain(:spotify_user, :following).with(args).and_raise(error) }

        it 'returns nil' do
          expect(fetch_batch_of_followed_artists).to be_nil
        end

        it 'logs an error' do
          expect(Rails.logger).to receive(:error).with(/Error fetching batch of artists from Spotify:/)
          fetch_batch_of_followed_artists
        end
      end
    end
  end
end