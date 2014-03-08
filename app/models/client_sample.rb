class ClientSample < ActiveRecord::Base
  before_save :sync_client_info
  belongs_to :browser, class_name: :ClientBrowser
  belongs_to :os, class_name: :ClientOS
  belongs_to :platform, class_name: :ClientPlatform

  PROTOCOLS = ['SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2']

private
  # Synchronises the useragent string with the individual columns.
  def sync_client_info
    if !useragent then
      return
    end

    ClientSample.transaction do |t|
      ua = UserAgent.parse(useragent)

      self.browser = ClientBrowser.find_or_create_by_browser(ua.browser)
      self.os = ClientOS.find_or_create_by_os(ua.os)
      self.platform = ClientPlatform.find_or_create_by_platform(ua.platform)
      self.version = ua.version.to_s
    end
  end
end
