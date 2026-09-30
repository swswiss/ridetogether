class AddElevationToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :elevation, :decimal, precision: 6, scale: 2
  end
end
