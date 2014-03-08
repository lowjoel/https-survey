class AddUseragentComponentsToClientSamples < ActiveRecord::Migration
  def change
    add_column :client_samples, :browser, :integer, after: :useragent
    add_column :client_samples, :version, :string, after: :browser
    add_column :client_samples, :platform, :integer, after: :version
    add_column :client_samples, :os, :integer, after: :platform

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
