require 'minitest/autorun'
require 'rexml/document'

class BookstarDistributionMetadataTest < Minitest::Test
  def ios_file(path)
    File.read(File.expand_path("../#{path}", __dir__))
  end

  def test_flutter_framework_declares_the_app_minimum_os
    plist = REXML::Document.new(ios_file('Flutter/AppFrameworkInfo.plist'))
    key = REXML::XPath.first(plist, '//key[text()="MinimumOSVersion"]')
    refute_nil key, 'App Store validation requires MinimumOSVersion'
    assert_equal '15.6', key.next_element.text
  end

  def test_unused_blocker_does_not_request_unapproved_distribution_entitlement
    refute_includes ios_file('Runner/Runner.entitlements'),
                    'com.apple.developer.family-controls'
    refute_includes ios_file('Runner.xcodeproj/project.pbxproj'),
                    'BOOKSTAR_ENABLE_FAMILY_CONTROLS'
  end
end
