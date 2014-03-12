require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

class MaintainTestResults
  def perform
    ServerSslTest.latest.where('last_tested < ?', Time.now - 1.day).each do |test|
      Delayed::Job.enqueue SsllabsCrawler.new(test.server.url)
    end
  end
end
