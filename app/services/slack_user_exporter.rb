# frozen_string_literal: true

class SlackUserExporter
  def initialize
    @client = Slack::Web::Client.new
  end

  def run
    @client.users_list['members'].slice(10..20).map do |member|
      id = member['id']
      name = member['name']
      real_name = member['real_name']
      profile = member['profile']

      puts "#{id} #{name} 取得中"

      image_path = extract_image_path(profile)
      uri = URI.parse(image_path)
      params = URI::decode_www_form(uri.query).to_h if uri.query
      ext = uri.path.match(/\A.*\.(.+)\Z/)[1]
      binding.pry
      sleep(1)
      open("./export/users/images/#{id}.#{ext}", 'wb') do |file|
        Faraday.new image_path
        response = Faraday.get image_path, params
        file.write(response.body)
      end

      hash = {
      id: id,
      name: name,
      real_name: real_name,
      }
      hash
    end
  end

  def extract_image_path(profile)
    %w(image_24 image_32 image_48 image_72 image_192 image_512 image_1024)
      .reverse
      .map { |attr| profile.dig(attr) }
      .compact
      .first
  end
end
