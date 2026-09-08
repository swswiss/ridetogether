class AddEstimatedDurationToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :estimated_duration_minutes, :integer
  end
end
