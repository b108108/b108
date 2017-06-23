module ExportBin
  class JsonDataClient
    def self.load_json(export_bin)
      # json_url="http://qa-gateway.cap.network/efficientm/exportbinjson/#{json_url}?apiKey=#{get_auth_token}"
      # uri = URI.parse(json_url)
      # http = Net::HTTP.new(uri.host, uri.port)
      # data = http.request(Net::HTTP::Get.new(uri.request_uri))
      # JSON.parse(data.body)
      json_url="#{Mandators.export_bin_url}/#{export_bin}"
      JSON.parse(get_response_body_from_url(json_url))
    end

    def self.get_response_body_from_url(url)
      uri = URI.parse("#{url}?apiKey=#{get_auth_token}")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request["X-Auth-Token"] = get_auth_token
      response = https.request(request)
      while response.code == '301' || response.code == '302'
        return download_image(response.header['location'])
      end
      response.body
    end

    private_class_method

    def self.download_image(url)
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = https.request(request)
      while response.code == '400'
        return https_download_image(url)
      end
      while response.code == '301' || response.code == '302'
        return download_image(response.header['location'])
      end
      response.body
    end

    def self.https_download_image(url)
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = https.request(request)

      response.body
    end

    def self.get_auth_token
      Session.current_user.auth_token
    end
  end
end
