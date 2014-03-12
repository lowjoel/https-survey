require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))
require 'nokogiri'
require 'open-uri'

class AlexaTopSitesCrawler
  def perform
    urls = get_urls
    update_top_500(urls)
  end

private
  # The URL for the n'th page of the top sites page
  ALEXA_SG_TOP_SITES_PAGE = 'http://www.alexa.com/topsites/countries;%d/SG'

  # Gets the URLs that are in the Alexa Top 500. They are ordered according to their position.
  def get_urls
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

    return sites
  end

  # Updates the list of top 500 sites. New sites are added, old sites are set to rank null.
  def update_top_500(sites)
    ServerMostVisit.transaction do
      ServerMostVisit.update_all 'rank = NULL'

      sites.each_index do |i|
        site = ServerMostVisit.find_or_create_by_url(sites[i])
        site.rank = i + 1
        site.save
      end
    end
  end
end

(AlexaTopSitesCrawler.new).perform
