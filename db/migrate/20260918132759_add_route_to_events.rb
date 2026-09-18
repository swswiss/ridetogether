class AddRouteToEvents < ActiveRecord::Migration[8.1]
  def change
    add_reference :events, :route, null: true, foreign_key: true
  end
end
