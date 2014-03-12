require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

# Finds all results more than one day old and schedules a SSLLabs analysis.
# TODO: These only do tests on servers which were tested before. We should see which servers are new!
class MaintainTestResults
  def perform
    ServerSslTest.latest.where('last_tested < ?', Time.now - 1.day).each do |test|
      Delayed::Job.enqueue SsllabsCrawler.new(test.server.url)
    end
  end
end
