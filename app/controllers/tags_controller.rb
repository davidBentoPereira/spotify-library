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
  #
  # end
  #
  # def update
  #   # TODO: Allow to rename a tag and give it a colour
  # end
  
  def destroy
    tag_to_delete = ActsAsTaggableOn::Tag.find(params[:id]).name
    current_user.delete_tags(tag_to_delete)

    if current_user.delete_tags(tag_params[:tag])
      redirect_to spotify_followed_artists_path
    else
      render spotify_followed_artists_path, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params.permit(:id, :tag)
  end
end
