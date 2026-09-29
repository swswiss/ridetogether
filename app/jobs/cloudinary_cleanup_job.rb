class CloudinaryCleanupJob < ApplicationJob
  queue_as :default

  def perform(public_id)
    CloudinaryDeleteService.call(public_id)
  end
end