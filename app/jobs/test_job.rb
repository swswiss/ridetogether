class TestJob < ApplicationJob
    queue_as :default
  
    def perform
      puts "🔥 TEST JOB EXECUTED"
    end
  end