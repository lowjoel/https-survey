class ServerSslTestResult < ActiveRecord::Base
  belongs_to :server_ssl_test

  RATINGS = ['F', 'E', 'D', 'C', 'B', 'A-', 'A', 'A+'].freeze
end
