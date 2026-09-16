class PostsController < ApplicationController
  include GroupContext

  layout "dashboard"

  before_action :set_event
  before_action :set_post, only: :destroy
  before_action :require_post_owner, only: :destroy

  def create
    @post = @event.posts.build(post_params)
    @post.user = Current.user

    if @post.save
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to group_event_path(@group, @event)
        end
      end
    else
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to group_event_path(@group, @event),
                      alert: @post.errors.full_messages.to_sentence
        end
      end
    end
  end

  def destroy
    @post.destroy
  
    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to group_event_path(@group, @event)
      end
    end
  end

  private

  def set_post
    @post = @event.posts.find(params[:id])
  end
  
  def require_post_owner
    unless @post.user_id == Current.user.id
      redirect_to group_event_path(@group, @event),
                  alert: "Nu ai permisiunea să ștergi această postare."
    end
  end

  def set_event
    @event = @group.events.find(params[:event_id])
  end

  def post_params
    params.require(:post).permit(:body)
  end
end