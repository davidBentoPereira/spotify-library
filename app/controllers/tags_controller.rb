class TagsController < ApplicationController
  # def new
  #   # TODO: Allow to create a tag with a name and a colour and associate it to the user
  # end
  #
  # def edit
  #   # TODO: Allow to rename a tag and give it a colour
  # end
  #
  # def create
  #   # TODO: Allow to create a tag with a name and a colour and associate it to the user
  # end
  #
  # def update
  #   # TODO: Allow to rename a tag and give it a colour
  # end

  def destroy
    load_tag

    if current_user.delete_tags(@tag)
      redirect_to spotify_followed_artists_path
    else
      render spotify_followed_artists_path, status: :unprocessable_entity
    end
  end

  private

  def load_tag
    @tag = ActsAsTaggableOn::Tag.find(tag_params[:id]).name
  end

  def tag_params
    params.permit(:id)
  end
end
