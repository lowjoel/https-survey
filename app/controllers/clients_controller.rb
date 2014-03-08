class ClientsController < ApplicationController
  def index
    # Compute aggregate statistics
    @ssl_versions = map_versions_to_strings(ClientSample.group(:protocol).count)
    @ssl_versions_by_platform = ClientSample.group(:platform_id, :protocol).count
    @ssl_versions_by_platform = map_platforms_to_strings(@ssl_versions_by_platform)
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
end
