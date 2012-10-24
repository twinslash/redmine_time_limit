require 'ipaddr'

class IpChecker

  attr_reader :ips

  def initialize(settings)
    @ips = parse(settings)
  end

  def trusted_ip?(remote_ip)
    ips.map { |ip| IPAddr.new(ip) === remote_ip }.include?(true)
  end

  private

    def parse(settings)
      settings.split("\r\n").map(&:strip).reject(&:empty?)
    end
end
