require 'minitest/autorun'
require 'tmpdir'
require_relative 'prepare_config'

class BookstarCloudConfigTest < Minitest::Test
  def payload
    BookstarCloudConfig::PATHS.to_h { |path| [path, Base64.strict_encode64('fixture')] }
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
        assert_equal 'fixture', File.read(File.join(root, path))
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
end
