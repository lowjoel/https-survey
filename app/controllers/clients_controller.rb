class ClientsController < ApplicationController
  def index
    # Compute aggregate statistics
    @ssl_versions = map_versions_to_strings(ClientSample.group(:protocol).count)
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
end
