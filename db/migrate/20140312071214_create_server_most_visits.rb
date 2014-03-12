class CreateServerMostVisits < ActiveRecord::Migration
  def change
    create_table :server_most_visits do |t|
      t.integer :rank
      t.string :url

      t.timestamps
    end

    add_index :server_most_visits, :url, unique: true
  end
end
