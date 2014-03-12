require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))
require 'nokogiri'
require 'open-uri'

class SsllabsCrawler < Struct.new(:url)
  def perform
    # Parse the URL, changing http:// to https://
    uri = URI.parse(url)
    host = URI("https://#{uri.host}")

    begin
      query(host)
    rescue => e
    end
  end

private
  # The summary results that the crawler returns after running SSLLab's tests.
  class Result
    def initialize
      @protocols = []
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
    ips.each do |ip|
      results[ip] = get_result_for_ip(url, ip)
    end
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
    doc.css('div#warningBox').each do |warning|
      raise StandardError.new(warning.content)
    end

    # See which protocols are supported
    result = Result.new
    table = doc.css('img[src="/images/icon-protocol.gif"]')[0].next_element
    versions = table.css('tbody > tr > td.tableLeft')
    compliances = table.css('tbody > tr > td.tableRight')

    for i in 0...versions.length do
      version = versions[i]
      compliance = compliances[i]
      result.protocols <<= version.content if compliance.content.strip == 'Yes'
    end

    return result
  end

private
  SSL_LABS_BASE_URL = 'https://www.ssllabs.com/ssltest/clearCache.html?hideResults=on&d=%s'
  SSL_LABS_RESULT_URL = 'https://www.ssllabs.com/ssltest/analyze.html?hideResults=on&d=%s'
  SSL_LABS_IP_RESULT_URL = 'https://www.ssllabs.com/ssltest/analyze.html?hideResults=on&d=%s&s=%s'
end

(SsllabsCrawler.new('https://cs2107.joelsplace.sg/')).perform
