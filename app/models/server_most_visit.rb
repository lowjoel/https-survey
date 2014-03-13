class ServerMostVisit < ActiveRecord::Base
  scope :tests, -> {
    join('LEFT OUTER JOIN server_ssl_tests ON server_most_visits.id=server_ssl_tests.server_most_visit_id')
  }
  
  has_many :server_ssl_test, alias: :tests
end
