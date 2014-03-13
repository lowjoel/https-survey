class ServerSslTest < ActiveRecord::Base
  # Selects the latest test for each server.
  scope :with_latest, -> { joins('INNER JOIN
    (SELECT server_most_visit_id, last_tested FROM server_ssl_tests GROUP BY last_tested) sst ON
    server_ssl_tests.server_most_visit_id=sst.server_most_visit_id AND
    server_ssl_tests.last_tested=sst.last_tested') }

  belongs_to :server, class_name: :ServerMostVisit
end
