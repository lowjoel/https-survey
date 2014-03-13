require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

# Finds all results more than one day old and schedules a SSLLabs analysis.
# TODO: These only do tests on servers which were tested before. We should see which servers are new!
module Crawler
  class MaintainTestResults
    def perform
      # Test all untested servers
      ServerMostVisit.with_untested.each do |server|
        Delayed::Job.enqueue SsllabsCrawler.new(server.url)
      end

      # Refresh all out-of-date tests
      ServerSslTest.with_latest.where('last_tested < ?', Time.now - 1.day) do |test|
        Delayed::Job.enqueue SsllabsCrawler.new(test.server.url)
      end
    end
  end
end
