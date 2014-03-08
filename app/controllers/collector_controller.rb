class CollectorController < ApplicationController
  # Fix the remote IP address if we are on the collect action.
  before_action :patch_ip, only: :collect

  # The ports corresponding to the ClientSample PROTOCOLS constant.
  COLLECTOR_PORTS = [8009, 8010, 8011, 8012]

  def index

  end

  def collect
    protocol = params[:protocol]
    case protocol
      when 'ssl3'
        protocol = 0
        cookie_sym = :client_collected_ssl3
      when 'tls1'
        protocol = 1
        cookie_sym = :client_collected_tls1
      when 'tls1.1'
        protocol = 2
        cookie_sym = :client_collected_tls11
      when 'tls1.2'
        protocol = 3
        cookie_sym = :client_collected_ssl12
      else
        return send_image
    end

    if cookies[cookie_sym] then
      return send_image
    end
    cookies[cookie_sym] = true

    headers = request.headers
    ClientSample.create({
                          protocol: protocol,
                          ip_address: headers['REMOTE_ADDR'],
                          useragent: headers['HTTP_USER_AGENT']
                        })

    send_image
  end

private
  def trusted_proxy?(ip)
    ip =~ /^127\.0\.0\.1$|^(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|^::1$|^fd[0-9a-f]{2}:.+|^localhost$/i
  end

  def patch_ip
    remote_addrs = request.headers['REMOTE_ADDR'] ? request.headers['REMOTE_ADDR'].split(/[,\s]+/) : []
    remote_addrs.reject! { |addr| trusted_proxy?(addr) }

    return if remote_addrs.any?

    forwarded_ips = request.headers['HTTP_X_FORWARDED_FOR'] ?
      request.headers['HTTP_X_FORWARDED_FOR'].strip.split(/[,\s]+/) : []
    logger.debug('remote_addrs: ' + remote_addrs.to_s)

    if client_ip = request.headers['HTTP_CLIENT_IP']
      # If forwarded_ips doesn't include the client_ip, it might be an
      # ip spoofing attempt, so we ignore HTTP_CLIENT_IP
      if forwarded_ips.include?(client_ip) then
        request.headers['REMOTE_ADDR'] = client_ip
        return
      end
    end

    logger.debug('forwarded_ips: ' + forwarded_ips.to_s)

    client_ip = forwarded_ips.reject { |ip| trusted_proxy?(ip) }.last
    request.headers['REMOTE_ADDR'] = client_ip if client_ip
  end

  def send_image
    blank_image = File.open(File.join(Rails.root, 'app/assets/images/blank.png'), 'rb') do |f|
      f.read
    end
    
    send_data(blank_image, type: 'image/png',
              disposition: 'inline')
  end
end
