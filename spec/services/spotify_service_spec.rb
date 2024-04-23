require "rails_helper"

RSpec.describe SpotifyService do
  let(:current_user) { create(:user, :with_spotify_data) }
  let(:spotify_user) { current_user.spotify_user }

  subject(:service) { described_class.new(spotify_user) }

  describe "public methods" do
    describe "#total_followed_artists" do
      before { allow(current_user).to receive(:spotify_user).and_return(spotify_user) }

      context 'when the Spotify API returns a valid response' do
        let(:response_body) { { "artists" => { "total" => 10 } }.to_json }

        before { allow(spotify_user).to receive(:following).with(type: 'artist').and_return(response_body) }

        it 'returns the total number of followed artists' do
          expect(service.total_followed_artists).to eq(10)
        end
      end

      context 'when the Spotify API returns an error response' do
        before do
          allow(spotify_user).to receive(:following).with(type: 'artist').and_raise(RestClient::ExceptionWithResponse)
        end

        it 'logs an error message and returns nil' do
          error_message = /Unexpected error when fetching total followed artists from Spotify/
          expect(Rails.logger).to receive(:error).with(error_message)
          expect(service.total_followed_artists).to be_nil
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

      subject(:fetch_all_followed_artists) { service.send(:fetch_all_followed_artists) }

      before do
        allow(service).to receive(:total_followed_artists).and_return(3)
        allow(service).to receive(:fetch_batch_of_followed_artists).with(nil).and_return(fetched_artists_batch1)
        allow(service).to receive(:fetch_batch_of_followed_artists).with('456').and_return(fetched_artists_batch2)
        allow(service).to receive(:fetch_batch_of_followed_artists).with('789').and_return(fetched_artists_batch3)
      end

      it 'fetches all followed artists from Spotify' do
        expect(fetch_all_followed_artists).to eq([artist1, artist2, artist3])
      end

      it 'calls fetch_batch_of_followed_artists with correct arguments' do
        expect(service).to receive(:fetch_batch_of_followed_artists).with(nil)
        expect(service).to receive(:fetch_batch_of_followed_artists).with('456')
        expect(service).not_to receive(:fetch_batch_of_followed_artists).with('789')
        fetch_all_followed_artists
      end

      it 'stops fetching if total number of fetched artists reaches or exceeds total number of followed artists' do
        allow(service).to receive(:total_followed_artists).and_return(1)
        expect(service).to receive(:fetch_batch_of_followed_artists).with(nil).and_return(fetched_artists_batch1)
        expect(service).not_to receive(:fetch_batch_of_followed_artists).with('456')
        expect(service).not_to receive(:fetch_batch_of_followed_artists).with('789')
        fetch_all_followed_artists
      end

      it 'stops fetching if maximum loop count is exceeded' do
        stub_const("SpotifyService::MAX_LOOP", -1)
        expect(service).to receive(:fetch_batch_of_followed_artists).once
        fetch_all_followed_artists
      end
    end

    describe "#artists" do
      context "when there are some fetched_artists" do
        let(:artist1) { double('RSpotify::Artist', name: "Artist 1", uri: "spotify:artist1", images: [{ "url" => "https://artist1.jpg" }]) }
        let(:artist2) { double('RSpotify::Artist', name: "Artist 2", uri: "spotify:artist2", images: [{ "url" => "https://artist2.jpg" }]) }
        let(:fetched_artists) { [artist1, artist2] }

        before { allow(service).to receive(:fetch_all_followed_artists).and_return(fetched_artists) }

        it "returns an array of Artist objects" do
          expect(service.artists.first).to be_an(Artist)
          expect(service.artists.first).to have_attributes(name: "Artist 1", external_link: "spotify:artist1", cover_url: "https://artist1.jpg")
          expect(service.artists.last).to be_an(Artist)
          expect(service.artists.last).to have_attributes(name: "Artist 2", external_link: "spotify:artist2", cover_url: "https://artist2.jpg")
        end
      end
    end
  end

  describe "private methods" do
    describe '#fetch_batch_of_followed_artists' do
      let(:last_artist_id) { '123456' }
      let(:args) { { type: 'artist', limit: described_class::SPOTIFY_MAX_LIMIT_PER_PAGE, after: last_artist_id } }

      subject(:fetch_batch_of_followed_artists) { service.send(:fetch_batch_of_followed_artists, last_artist_id) }

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