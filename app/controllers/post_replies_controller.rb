class PostRepliesController < ApplicationController
  include GroupContext

  layout "dashboard"

  before_action :set_event
  before_action :set_post
  before_action :set_reply, only: :destroy
  before_action :require_reply_owner, only: :destroy

  def create
    @reply = @post.post_replies.build(reply_params)
    @reply.user = Current.user

    if @reply.save
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to group_event_path(@group, @event)
        end
      end
    else
      redirect_to group_event_path(@group, @event),
                  alert: @reply.errors.full_messages.to_sentence
    end
  end

  def destroy
    @reply.destroy

    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to group_event_path(@group, @event)
      end
    end
  end

  private

  def set_event
    @event = @group.events.find(params[:event_id])
  end

  def set_post
    @post = @event.posts.find(params[:post_id])
  end

  def set_reply
    @reply = @post.post_replies.find(params[:id])
  end

  def require_reply_owner
    unless @reply.user_id == Current.user.id
      redirect_to group_event_path(@group, @event),
                  alert: "Nu ai permisiunea să ștergi acest răspuns."
    end
  end

  def reply_params
    params.require(:post_reply).permit(:body)
  end
end