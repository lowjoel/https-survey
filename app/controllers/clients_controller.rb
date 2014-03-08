class ClientsController < ApplicationController
  def index
    # Compute aggregate statistics
    @ssl_versions = map_versions_to_strings(ClientSample.group(:protocol).count)
    @ssl_versions_by_platform = ClientSample.group(:platform_id, :protocol).count
    @ssl_versions_by_platform = map_platforms_to_strings(@ssl_versions_by_platform)
    @ssl_versions_by_browser = ClientSample.group(:browser_id, :protocol).count
    @ssl_versions_by_browser = map_browsers_to_strings(@ssl_versions_by_browser)
  end

  def privacy

  end

private
  def map_versions_to_strings(versions)
    result = {}
    versions.each_pair do |key, value|
      result[ClientSample::PROTOCOLS[key]] = value
    end

    return result
  end

  def map_platforms_to_strings(platforms)
    result = {}
    all_platforms = {}
    ClientPlatform.all.each do |p|
      all_platforms[p.id] = p.platform
    end

    platforms.each_pair do |key, value|
      platform = all_platforms[key[0]]
      protocol = key[1]
      result[platform] = {} unless result[platform]
      result[platform][protocol] = value
    end

    result2 = {}
    result.each_pair do |platform, value|
      map_versions_to_strings(value).each_pair do |protocol, value|
        result2["#{platform}, #{protocol}"] = value
      end
    end

    return result2
  end

  def map_browsers_to_strings(browsers)
    result = {}
    all_browsers = {}
    ClientBrowser.all.each do |p|
      all_browsers[p.id] = p.browser
    end

    browsers.each_pair do |key, value|
      browser = all_browsers[key[0]]
      protocol = key[1]
      result[browser] = {} unless result[browser]
      result[browser][protocol] = value
    end

    result2 = {}
    result.each_pair do |browser, value|
      map_versions_to_strings(value).each_pair do |protocol, value|
        result2["#{browser}, #{protocol}"] = value
      end
    end

    return result2
  end
end
