class AddIpAddressToClientSamples < ActiveRecord::Migration
  def change
    add_column :client_samples, :ip_address, :string, after: :id
  end
end
