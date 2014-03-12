require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))
require 'nokogiri'
require 'open-uri'

class AlexaTopSitesCrawler
  def perform
    sites = []
    for page in 0..19 do
      url = ALEXA_SG_TOP_SITES_PAGE % [page]
      puts "Retrieving #{url}..."
      doc = Nokogiri::HTML(open(url))

      # Find the set of containers containing the listings
      doc.css('div#topsites-countries > div > ul > li.site-listing > div.desc-container > h2 > a').each do |link|
        sites <<= link.content
      end

      sleep(1)
    end
  end

private
  # The URL for the n'th page of the top sites page
  ALEXA_SG_TOP_SITES_PAGE = 'http://www.alexa.com/topsites/countries;%d/SG'
end

(AlexaTopSitesCrawler.new).perform
