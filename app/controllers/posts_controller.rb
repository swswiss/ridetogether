class PostsController < ApplicationController
  include GroupContext

  layout "dashboard"

  before_action :set_event

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

  private

  def set_event
    @event = @group.events.find(params[:event_id])
  end

  def post_params
    params.require(:post).permit(:body)
  end
end