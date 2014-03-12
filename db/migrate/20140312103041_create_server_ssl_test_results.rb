class CreateServerSslTestResults < ActiveRecord::Migration
  def change
    create_table :server_ssl_test_results do |t|
      t.string ip
      t.boolean :ssl3
      t.boolean :tls1
      t.boolean :tls11
      t.boolean :tls12
      t.integer :grade
      
      t.timestamps
    end
  end
end
