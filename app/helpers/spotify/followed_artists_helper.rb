# frozen_string_literal: true

module Spotify
  module FollowedArtistsHelper
    include ActsAsTaggableOn::TagsHelper

    def badge_css_classes
      %w[badge-gray badge-red badge-yellow badge-green badge-blue badge-indigo badge-purple badge-pink]
    end
  end
end