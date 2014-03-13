class ServerMostVisit < ActiveRecord::Base
  scope :with_untested, -> {
    joins('LEFT OUTER JOIN server_ssl_tests ON server_most_visits.id=server_ssl_tests.server_most_visit_id').
    where('server_ssl_tests.id IS NULL')
  }

  has_many :server_ssl_test
  alias :tests :server_ssl_test
end
