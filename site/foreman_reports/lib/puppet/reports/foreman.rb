# Fixed version of theforeman-foreman's report processor.
#
# Two changes from the Forge module's own files/foreman-report_v2.rb:
#   1. Lives under lib/puppet/reports/ (this module's real location),
#      the path pluginsync actually looks at — the original ships
#      under files/, meant for manual copying, which pluginsync
#      silently deletes as unmanaged drift on every agent run.
#   2. $settings_file corrected to the modern AIO path
#      (/etc/puppetlabs/puppet/foreman.yaml) — the original hardcodes
#      the old Puppet 3-era /etc/puppet/foreman.yaml.

require 'puppet'
require 'net/http'
require 'net/https'
require 'rbconfig'
require 'uri'
require 'yaml'
begin
  require 'json'
rescue LoadError
  begin
    require 'rubygems' rescue nil
    require 'json'
  rescue LoadError => e
    puts "You need the `json` gem to use the Foreman ENC script"
    exit 2
  end
end

if RbConfig::CONFIG['host_os'] =~ /freebsd|dragonfly/i
  $settings_file = "/usr/local/etc/puppetlabs/puppet/foreman.yaml"
else
  $settings_file = "/etc/puppetlabs/puppet/foreman.yaml"
end

SETTINGS = YAML.load_file($settings_file)

Puppet::Reports.register_report(:foreman) do
  Puppet.settings.use(:reporting)
  desc "Sends reports directly to Foreman"

  def process
    begin
      raise(Puppet::ParseError, "Invalid report: can't find metrics information for #{self.host}") if self.metrics.nil?

      uri = URI.parse(foreman_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = uri.scheme == 'https'
      if http.use_ssl?
        if SETTINGS[:ssl_ca] && !SETTINGS[:ssl_ca].empty?
          http.ca_file = SETTINGS[:ssl_ca]
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        else
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        if SETTINGS[:ssl_cert] && !SETTINGS[:ssl_cert].empty? && SETTINGS[:ssl_key] && !SETTINGS[:ssl_key].empty?
          http.cert = OpenSSL::X509::Certificate.new(File.read(SETTINGS[:ssl_cert]))
          http.key  = OpenSSL::PKey::RSA.new(File.read(SETTINGS[:ssl_key]), nil)
        end
      end
      req = Net::HTTP::Post.new("#{uri.path}/api/reports")
      req.add_field('Accept', 'application/json,version=2' )
      req.content_type = 'application/json'
      req.body         = {'report' => generate_report}.to_json
      response = http.request(req)
    rescue Exception => e
      raise Puppet::Error, "Could not send report to Foreman at #{foreman_url}/api/reports: #{e}\n#{e.backtrace}"
    end
  end

  def generate_report
    report = {}
    set_report_format
    report['host'] = self.host
    report['reported_at'] = self.time.utc.strftime("%Y-%m-%d %H:%M:%S UTC")
    report['status'] = metrics_to_hash(self)
    report['metrics'] = m2h(self.metrics)
    report['logs'] = logs_to_array(self.logs)
    report
  end

  private

  METRIC = %w[applied restarted failed failed_restarts skipped pending]

  def metrics_to_hash(report)
    report_status = {}
    metrics = self.metrics
    METRIC.each do |m|
      if @format == 0
        report_status[m] = metrics["resources"][m.to_sym] unless metrics["resources"].nil?
      else
        h=translate_metrics_to26(m)
        mv = metrics[h[:type]]
        report_status[m] = mv[h[:name].to_sym] + mv[h[:name].to_s] rescue nil
      end
      report_status[m] ||= 0
    end
    if report_status["skipped"] > 0 and ((report_status.values.inject(:+)) - report_status["skipped"] == report.logs.size)
      report_status["skipped"] = 0
    end
    if @format > 1 and report.respond_to?(:status) and report.status == "failed"
      report_status["failed"] += 1
    end
    report_status["failed"] += report.logs.find_all {|l| l.source =~ /Puppet$/ && l.level.to_s == 'err' }.count
    return report_status
  end

  def m2h metrics
    h = {}
    metrics.each do |title, mtype|
      h[mtype.name] ||= {}
      mtype.values.each{|m| h[mtype.name].merge!({m[0].to_s => m[2]})}
    end
    return h
  end

  def logs_to_array logs
    h = []
    logs.each do |log|
      next if log.level == :debug
      next if log.message =~ /^Finished catalog run in \d+.\d+ seconds$/
      l = { 'log' => { 'sources' => {}, 'messages' => {} } }
      l['log']['level'] = log.level.to_s
      l['log']['messages']['message'] = log.message
      l['log']['sources']['source'] = log.source
      h << l
    end
    return h
  end

  def translate_metrics_to26 metric
    case metric
    when "applied"
      case @format
      when 0..1
        { :type => "total", :name => :changes}
      else
        { :type => "changes", :name => "total"}
      end
    when "failed_restarts"
      case @format
      when 0..1
        { :type => "resources", :name => metric}
      else
        { :type => "resources", :name => "failed_to_restart"}
      end
    when "pending"
      { :type => "events", :name => "noop" }
    else
      { :type => "resources", :name => metric}
    end
  end

  def set_report_format
    @format ||= case
                when self.instance_variables.detect {|v| v.to_s == "@environment"}
                  @format = 3
                when self.instance_variables.detect {|v| v.to_s == "@report_format"}
                  @format = 2
                when self.instance_variables.detect {|v| v.to_s == "@resource_statuses"}
                  @format = 1
                else
                  @format = 0
                end
  end

  def foreman_url
    SETTINGS[:url] || raise(Puppet::Error, "Must provide URL in #{$settings_file}")
  end

end
