module Crawler
  class CrawlerError < StandardError
    def initialize(*args)
      super.initialize(*args)
    end
  end
end
