class CollectorController < ApplicationController
  # Fix the remote IP address if we are on the collect action.
  before_action :patch_ip, only: :collect

  # The ports corresponding to the ClientSample PROTOCOLS constant.
  COLLECTOR_PORTS = [8009, 8010, 8011, 8012]

  # These browsers will be ignored.
  BLACKLISTED_BROWSERS = (Set.new ['facebookexternalhit']).freeze

  def index

  end

  def collect
    headers = request.headers
    if is_blacklisted?(headers['HTTP_USER_AGENT'])
      logger.info("Ignoring #{headers['HTTP_USER_AGENT']}")
      return send_image
    end

    protocol = params[:protocol]
    case protocol
      when 'ssl3'
        protocol = 0
        cookie_sym = :client_collected_ssl3
      when 'tls1'
        protocol = 1
        cookie_sym = :client_collected_tls1
      when 'tls11'
        protocol = 2
        cookie_sym = :client_collected_tls11
      when 'tls12'
        protocol = 3
        cookie_sym = :client_collected_ssl12
      else
        return send_image
    end

    if cookies[cookie_sym] then
      return send_image
    end
    cookies.permanent[cookie_sym] = true

    ClientSample.create({
                          protocol: protocol,
                          ip_address: headers['REMOTE_ADDR'],
                          useragent: headers['HTTP_USER_AGENT']
                        })

    send_image
  end

private
  def is_blacklisted?(useragent)
    ua = UserAgent.parse(useragent)
    return BLACKLISTED_BROWSERS.include?(ua.browser)
  end

  def send_image
    blank_image = File.open(File.join(Rails.root, 'app/assets/images/blank.png'), 'rb') do |f|
      f.read
    end
    
    send_data(blank_image, type: 'image/png',
              disposition: 'inline')
  end
end
