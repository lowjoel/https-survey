class CreateClientSamples < ActiveRecord::Migration
  def change
    create_table :client_samples do |t|
      t.integer :protocol
      t.string :useragent

      t.timestamps
    end
  end
end
