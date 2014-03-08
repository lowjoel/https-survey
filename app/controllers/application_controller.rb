class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private
  def trusted_proxy?(ip)
    ip =~ /^127\.0\.0\.1$|^(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|^::1$|^fd[0-9a-f]{2}:.+|^localhost$/i
  end

protected
  # This will parse any proxy forwarding headers. This can be used as an action filter, like so:
  # before_action :patch_ip
  def patch_ip
    remote_addrs = request.headers['REMOTE_ADDR'] ? request.headers['REMOTE_ADDR'].split(/[,\s]+/) : []
    remote_addrs.reject! { |addr| trusted_proxy?(addr) }

    return if remote_addrs.any?

    forwarded_ips = request.headers['HTTP_X_FORWARDED_FOR'] ?
      request.headers['HTTP_X_FORWARDED_FOR'].strip.split(/[,\s]+/) : []
    logger.info('remote_addrs: ' + remote_addrs.to_s)

    if client_ip = request.headers['HTTP_CLIENT_IP']
      # If forwarded_ips doesn't include the client_ip, it might be an
      # ip spoofing attempt, so we ignore HTTP_CLIENT_IP
      if forwarded_ips.include?(client_ip) then
        request.headers['REMOTE_ADDR'] = client_ip
        return
      end
    end

    logger.info('forwarded_ips: ' + forwarded_ips.to_s)

    client_ip = forwarded_ips.reject { |ip| trusted_proxy?(ip) }.last
    request.headers['REMOTE_ADDR'] = client_ip if client_ip
  end
end
