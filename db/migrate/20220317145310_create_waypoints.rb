class CreateWaypoints < ActiveRecord::Migration[7.0]
  def change
    create_table :waypoints do |t|
      t.string :title
      t.float :longitude
      t.float :latitude
      t.float :elevation
      t.json :geocode
      t.datetime :external_created_at
      t.datetime :external_updated_at
      t.integer :external_id
      t.string :external_name

      t.timestamps
    end
  end
end