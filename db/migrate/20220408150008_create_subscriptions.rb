class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :email
      t.boolean :confirmed
      t.string :token
      t.timestamps
    end
  end
end
