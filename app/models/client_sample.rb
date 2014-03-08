class ClientSample < ActiveRecord::Base
  before_save :sync_client_info

  PROTOCOLS = ['SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2']

private
  # Synchronises the useragent string with the individual columns.
  def sync_client_info
    ##TODO: implement this.
  end
end
