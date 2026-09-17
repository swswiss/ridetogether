class PostLikesController < ApplicationController
  include GroupContext

  layout "dashboard"

  before_action :set_event
  before_action :set_post

  def create
    like = @post.post_likes.find_by(user: Current.user)

    if like
      like.destroy
    else
      @post.post_likes.create(user: Current.user)
    end

    @post.reload
    @post.post_likes.reset

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to group_event_path(@group, @event) }
    end
  end

  private

  def set_event
    @event = @group.events.find(params[:event_id])
  end

  def set_post
    @post = @event.posts.find(params[:post_id])
  end
end
