class NonUniqueServerSslTestMostVisitId < ActiveRecord::Migration
  def change
    remove_index :server_ssl_tests, :server_most_visit_id
    add_index :server_ssl_tests, :server_most_visit_id
  end
end
