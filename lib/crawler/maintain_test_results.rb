require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

# Finds all results more than one day old and schedules a SSLLabs analysis.
module Crawler
  class MaintainTestResults
    def perform
      # Test all untested servers
      ServerMostVisit.with_untested.each do |server|
        Delayed::Job.enqueue SsllabsCrawler.new(server.url)
      end

      # Refresh all out-of-date tests
      ServerSslTest.with_latest.where('last_tested < ?', Time.now - 7.day) do |test|
        Delayed::Job.enqueue SsllabsCrawler.new(test.server.url)
      end

      # Refresh a smattering of those which are up-to-date so we stagger the update times
      tests_count = ServerSslTest.with_latest.count
      ServerSslTest.with_latest.where('server_ssl_tests.last_tested > ? AND
                                       server_ssl_tests.last_tested < ?',
                                      Time.now - 7.day, Time.now - 1.day).
                                random(tests_count / 10).each do |test|
        Delayed::Job.enqueue SsllabsCrawler.new(test.server.url)
      end
    end
  end
end

Crawler::MaintainTestResults.new.perform