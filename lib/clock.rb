require 'clockwork'
require '../config/boot'
require '../config/environment'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  every(1.day, 'alexa.refresh', :at => '00:00') do
    Delayed::Job.enqueue AlexaTopSitesCrawler.new
  end
  every(1.day, 'ssl_test.refresh', :at => '00:30') do
    Delayed::Job.enqueue MaintainTestResults.new
  end
end