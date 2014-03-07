class CollectorController < ApplicationController

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
                          useragent: headers['HTTP_USER_AGENT']
                        })

    send_image
  end

private
  def send_image
    blank_image = File.open(File.join(Rails.root, 'app/assets/images/blank.png'), 'rb') do |f|
      f.read
    end
    
    send_data(blank_image, type: 'image/png',
              disposition: 'inline')
  end
end
