class CreateServerSslTests < ActiveRecord::Migration
  def change
    create_table :server_ssl_tests do |t|
      t.integer :server_most_visit_id
      t.timestamp :last_tested

      t.timestamps
    end

    add_index :server_ssl_tests, :server_most_visit_id, unique: true
  end
end
