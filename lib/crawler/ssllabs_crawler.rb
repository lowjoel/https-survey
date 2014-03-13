require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))
require 'nokogiri'
require 'open-uri'

module Crawler
  class SsllabsCrawler < Struct.new(:hostname)
    def perform
      # Parse the URL, changing http:// to https://
      host = URI("https://#{hostname}")

      begin
        # Perform the look up
        results = query(host)

        # Store it into the database
        ServerSslTest.transaction do
          server = ServerMostVisit.find_or_create_by_url(hostname)

          test = ServerSslTest.new(server_most_visit: server,
                                   last_tested: Time.now)
          results.each_pair do |ip, result|
            next if !result
            ServerSslTestResult.create(server_ssl_test: test,
                                       ip: ip,
                                       ssl3: result.protocols.include?(:ssl3),
                                       tls1: result.protocols.include?(:tls1),
                                       tls11: result.protocols.include?(:tls11),
                                       tls12: result.protocols.include?(:tls12),
                                       grade: result.rating)
          end

          test.save
        end
      rescue => e
        raise e
      end
    end

  private
    # The summary results that the crawler returns after running SSLLab's tests.
    class Result
      def initialize
        @protocols = []
      end

      def rating
        @rating
      end

      def rating=(value)
        @rating = value
      end

      def protocols
        @protocols
      end

      def protocols=(value)
        @protocols = value
      end
    end

    # Queries SSLLabs for the HTTPS implementation of the given site.
    # @raise Exception If there was an error testing the site.
    # @return An array containing one result for each IP of the site.
    def query(url)
      # Clear the cache and trigger the test.
      start(url)

      # We can wait for about 15 seconds.
      sleep(15)

      # See if we have a multi-site result
      ips = get_ips(url)

      results = {}
      if ips.count == 0 then
        results[nil] = get_result_for_ip(url)
      else
        ips.each do |ip|
          results[ip] = get_result_for_ip(url, ip)
        end
      end

      return results
    end

    # Starts the test
    def start(url)
      open(SSL_LABS_BASE_URL % [url]).read()
    end

    # Gets the IP Addresses that SSLLabs has found the site with.
    def get_ips(url)
      doc = Nokogiri::HTML(open(SSL_LABS_RESULT_URL % [url]))

      if doc.css('table#multiTable').count == 0 then
        return []
      end

      ips = []
      doc.css('table#multiTable tr td > span.ip > b > a').each do |link|
        ips <<= link.content
      end

      return ips
    end

    # Gets the result for the given IP
    def get_result_for_ip(url, ip = nil)
      url = ip ? (SSL_LABS_IP_RESULT_URL % [url, ip]) : (SSL_LABS_RESULT_URL % [url])
      doc = Nokogiri::HTML(open(url))

      # Wait for the results to be out.
      while doc.css('div#warningBox img[src="/images/progress-indicator.gif"]').count > 0 do
        sleep(60)
        doc = Nokogiri::HTML(open(url))
      end

      # Check that we do not have an error
      result = Result.new
      doc.css('div#warningBox').each do |warning|
        warning = warning.content
        if warning.include? 'Certificate name mismatch' || warning.include? 'Unable to connect to server' then
          result = nil
        else
          raise StandardError.new(warning)
        end
      end

      if !result then
        return nil
      end

      # See the grade of the server
      doc.css('div#rating > div.rating_g, div#rating > div.rating_a, div#rating > div.rating_r').each do |span|
        result.rating = case span.content.strip
                          when 'F'
                            0
                          when 'E'
                            1
                          when 'D'
                            2
                          when 'C'
                            3
                          when 'B'
                            4
                          when 'A-'
                            5
                          when 'A'
                            6
                          when 'A+'
                            7
                        end
      end

      # See which protocols are supported
      table = doc.css('img[src="/images/icon-protocol.gif"]')[0].next_element
      versions = table.css('tbody > tr > td.tableLeft')
      compliances = table.css('tbody > tr > td.tableRight')

      for i in 0...versions.length do
        version = versions[i]
        compliance = compliances[i]
        result.protocols <<= case version.content.strip
                               when 'TLS 1.2'
                                 :tls12
                               when 'TLS 1.1'
                                 :tls11
                               when 'TLS 1.0'
                                 :tls1
                               when 'SSL 3'
                                 :ssl3
                               when 'SSL 2'
                                 :ssl2
                             end if compliance.content.strip == 'Yes'
      end

      return result
    end

  private
    SSL_LABS_BASE_URL = 'https://www.ssllabs.com/ssltest/clearCache.html?hideResults=on&d=%s'
    SSL_LABS_RESULT_URL = 'https://www.ssllabs.com/ssltest/analyze.html?hideResults=on&d=%s'
    SSL_LABS_IP_RESULT_URL = 'https://www.ssllabs.com/ssltest/analyze.html?hideResults=on&d=%s&s=%s'
  end
end
