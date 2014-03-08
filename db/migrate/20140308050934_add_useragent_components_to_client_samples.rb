class AddUseragentComponentsToClientSamples < ActiveRecord::Migration
  def change
    add_column :client_samples, :browser_id, :integer, after: :useragent
    add_column :client_samples, :version, :string, after: :browser_id
    add_column :client_samples, :platform_id, :integer, after: :version
    add_column :client_samples, :os_id, :integer, after: :platform_id

    create_table :client_browsers do |t|
      t.string :browser

      t.timestamps
    end

    create_table :client_platforms do |t|
      t.string :platform

      t.timestamps
    end

    create_table :client_oses do |t|
      t.string :os

      t.timestamps
    end
  end
end
