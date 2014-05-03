class ServerSslTest < ActiveRecord::Base
  # Selects the latest test for each server.
  scope :with_latest, -> { joins('INNER JOIN
    (SELECT server_most_visit_id, last_tested FROM server_ssl_tests GROUP BY server_most_visit_id) sst ON
    server_ssl_tests.server_most_visit_id=sst.server_most_visit_id AND
    server_ssl_tests.last_tested=sst.last_tested') }

  belongs_to :server_most_visit
  has_many :server_ssl_test_results
  alias :results :server_ssl_test_results
  alias :server :server_most_visit
end
