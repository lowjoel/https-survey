class AddServerSslTestResultError < ActiveRecord::Migration
  def change
    add_column :server_ssl_test_results, :error, :text, after: :ip
  end
end
