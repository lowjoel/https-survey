module Crawler
  class CrawlerError < StandardError
    def initialize(*args)
      super(*args)
    end
  end
end
