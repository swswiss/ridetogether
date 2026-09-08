class AddStravaLinkToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :strava_link, :string
  end
end
