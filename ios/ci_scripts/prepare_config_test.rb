require 'minitest/autorun'
require 'tmpdir'
require_relative 'prepare_config'

class BookstarCloudConfigTest < Minitest::Test
  def payload
    files = BookstarCloudConfig::PATHS.to_h { |path| [path, 'fixture'] }
    files['assets/env/.env'] = "BASE_URL=https://beta.bookstar.trade\nKAKAO_NATIVE_KEY=#{'a' * 32}\n"
    files['ios/Flutter/Keys.xcconfig'] = "KAKAO_NATIVE_APP_KEY = #{'a' * 32}\n"
    files.transform_values { |value| Base64.strict_encode64(value) }
  end

  def validate(data = payload, origin = 'https://beta.bookstar.trade', number = '402')
    BookstarCloudConfig.validate(JSON.generate(data), origin, number)
  end

  def test_restores_only_approved_files_with_private_permissions
    Dir.mktmpdir('bookstar-cloud-config-test') do |root|
      env = {'BOOKSTAR_IOS_CONFIG_JSON' => JSON.generate(payload),
             'BOOKSTAR_API_BASE_URL' => 'https://beta.bookstar.trade',
             'CI_BUILD_NUMBER' => '402'}
      BookstarCloudConfig.install(env, root)
      BookstarCloudConfig::PATHS.each do |path|
        assert_equal Base64.strict_decode64(payload.fetch(path)), File.read(File.join(root, path))
        assert_equal 0o600, File.stat(File.join(root, path)).mode & 0o777
      end
    end
  end

  def test_rejects_production_localhost_and_untrusted_origins
    %w[https://bookstar.trade http://beta.bookstar.trade https://localhost
       https://beta.bookstar.trade.evil.example https://user@beta.bookstar.trade
       https://beta.bookstar.trade/path https://beta.bookstar.trade?token=x].each do |origin|
      assert_raises(ArgumentError) { validate(payload, origin) }
    end
  end

  def test_allows_authorized_production_cutover_only_from_build_406
    data = payload.merge('assets/env/.env' =>
                         Base64.strict_encode64("BASE_URL=https://bookstar.trade\nKAKAO_NATIVE_KEY=#{'a' * 32}\n"))
    assert_equal "BASE_URL=https://bookstar.trade\nKAKAO_NATIVE_KEY=#{'a' * 32}\n",
                 validate(data, 'https://bookstar.trade', '406').fetch('assets/env/.env')
    assert_raises(ArgumentError) { validate(data, 'https://bookstar.trade', '405') }
    %w[https://book.trade https://bookstar.trade.evil.example https://user@bookstar.trade
       https://bookstar.trade/path http://bookstar.trade https://bookstar.trade:444].each do |origin|
      assert_raises(ArgumentError) { validate(data, origin, '406') }
    end
  end

  def test_rejects_missing_extra_and_traversal_paths
    missing = payload.reject { |path, _| path == 'assets/env/.env' }
    assert_raises(ArgumentError) { validate(missing) }
    assert_raises(ArgumentError) { validate(payload.merge('../outside' => 'YQ==')) }
  end

  def test_rejects_reused_or_invalid_build_numbers
    %w[1 100 401 abc 402.0].each do |number|
      assert_raises(ArgumentError) { validate(payload, 'https://beta.bookstar.trade', number) }
    end
  end

  def test_rejects_empty_invalid_base64_and_placeholder_files
    ['', 'not base64', Base64.strict_encode64('stub')].each do |value|
      data = payload.merge('ios/Flutter/Keys.xcconfig' => value)
      assert_raises(ArgumentError) { validate(data) }
    end
  end

  def test_rejects_kakao_sdk_and_callback_key_mismatch
    data = payload.merge('ios/Flutter/Keys.xcconfig' =>
                         Base64.strict_encode64("KAKAO_NATIVE_APP_KEY = #{'b' * 32}\n"))
    assert_raises(ArgumentError) { validate(data) }
  end

  def test_rejects_missing_malformed_and_duplicate_native_keys
    ['', 'KAKAO_NATIVE_KEY=bad', "KAKAO_NATIVE_KEY=#{'a' * 32}\nKAKAO_NATIVE_KEY=#{'b' * 32}"].each do |key|
      data = payload.merge('assets/env/.env' =>
                           Base64.strict_encode64("BASE_URL=https://beta.bookstar.trade\n#{key}\n"))
      assert_raises(ArgumentError) { validate(data) }
    end
  end

  def test_rejects_app_origin_that_disagrees_with_cloud_origin
    data = payload.merge('assets/env/.env' =>
                         Base64.strict_encode64("BASE_URL=https://bookstar.trade\nKAKAO_NATIVE_KEY=#{'a' * 32}\n"))
    assert_raises(ArgumentError) { validate(data) }
  end
end
