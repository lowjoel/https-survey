class AddIndicesToClientSamples < ActiveRecord::Migration
  def change
    add_index :client_browsers, :browser, unique: true
    add_index :client_oses, :os, unique: true
    add_index :client_platforms, :platform, unique: true

    add_index :client_samples, :protocol
    add_index :client_samples, :browser_id
    add_index :client_samples, :os_id
    add_index :client_samples, :platform_id
  end
end
