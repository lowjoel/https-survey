class ServersController < ApplicationController
  def index
    @protocols = {
      'SSL v3' => 0,
      'TLS v1' => 0,
      'TLS v1.1' => 0,
      'TLS v1.2' => 0
    }
    ratings = [0, 0, 0, 0, 0, 0, 0, 0]

    ServerSslTest.with_latest.each do |site|
      site.results.each do |result|
        @protocols['SSL v3'] += result.ssl3 ? 1 : 0
        @protocols['TLS v1'] += result.tls1 ? 1 : 0
        @protocols['TLS v1.1'] += result.tls11 ? 1 : 0
        @protocols['TLS v1.2'] += result.tls12 ? 1 : 0
        if result.grade then
          ratings[result.grade] += 1
        end
      end
    end

    @ratings = {};
    ratings.each_index {|index| @ratings[ServerSslTestResult::RATINGS[index]] = ratings[index]}
  end
end