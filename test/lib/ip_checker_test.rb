require File.expand_path(File.dirname(__FILE__) + '/../../lib/ip_checker')
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

class IpCheckerTest < ActiveSupport::TestCase

  checker = IpChecker.new("  127.0.0.1 \r\n \r\n\r\n \r\n169.168.1.1\r\n 13.13.13.13/13 \r\n \r\n\r\n")

  test "should initialize with list of ip" do
    assert_equal checker.ips.sort, ['127.0.0.1', '169.168.1.1', '13.13.13.13/13'].sort
  end

  test "should return true if ip trusted" do
    assert checker.trusted_ip?('13.13.13.15')
  end

  test "should return false if ip not trusted" do
    assert_equal checker.trusted_ip?('111.111.111.111'), false
  end
end
