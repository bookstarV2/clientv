require 'base64'
require 'fileutils'
require 'json'
require 'uri'

module BookstarCloudConfig
  PATHS = %w[
    assets/env/.env
    lib/firebase_options.dart
    ios/Runner/GoogleService-Info.plist
    ios/Flutter/Keys.xcconfig
  ].freeze

  def self.validate(payload, origin, build_number)
    uri = URI.parse(origin)
    unless uri.scheme == 'https' && uri.host == 'beta.bookstar.trade' &&
           uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil? &&
           ['', '/'].include?(uri.path) && uri.port == 443
      raise ArgumentError, 'Use the isolated beta.bookstar.trade HTTPS origin'
    end
    unless build_number.match?(/\A[0-9]+\z/) && build_number.to_i >= 402
      raise ArgumentError, 'Set Xcode Cloud Next Build Number to at least 402'
    end

    encoded = JSON.parse(payload)
    unless encoded.is_a?(Hash) && encoded.keys.sort == PATHS.sort
      raise ArgumentError, 'Cloud configuration must contain exactly the four approved app files'
    end
    decoded = encoded.transform_values { |value| Base64.strict_decode64(value) }
    if decoded.values.any? { |value| value.strip.empty? }
      raise ArgumentError, 'Cloud configuration files must not be empty'
    end
    keys = decoded.fetch('ios/Flutter/Keys.xcconfig')
    if keys.match?(/stub|placeholder|YOUR_/i)
      raise ArgumentError, 'Replace placeholder iOS login configuration before building'
    end
    decoded
  end

  def self.install(environment, root)
    files = validate(environment.fetch('BOOKSTAR_IOS_CONFIG_JSON'),
                     environment.fetch('BOOKSTAR_API_BASE_URL'),
                     environment.fetch('CI_BUILD_NUMBER'))
    files.each do |relative_path, content|
      destination = File.join(root, relative_path)
      FileUtils.mkdir_p(File.dirname(destination))
      File.write(destination, content, perm: 0o600)
      File.chmod(0o600, destination)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    BookstarCloudConfig.install(ENV, ENV.fetch('CI_PRIMARY_REPOSITORY_PATH'))
    puts 'Private app configuration restored; values are not logged.'
  rescue StandardError
    warn 'Cloud configuration rejected. Check the four-file secret, beta origin, login keys and build number.'
    exit 1
  end
end
