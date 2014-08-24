require 'puppet'
require 'fileutils'
require 'puppet/util'

##
## active_support/core_ext is used to build the XML
##
begin
  require 'active_support/core_ext'
rescue LoadError => e
  Puppet.info "You need the activesupport gem to use this"
end

Puppet::Reports.register_report(:store_xml) do

  desc <<-DESC
  Store reports as XML
  DESC

  def process

    dir = File.join(Puppet[:reportdir], 'xml', self.host)

    ## Ensure a report directory exists for these reports
    begin
      if ! Puppet::FileSystem.exist?(dir)
        FileUtils.mkdir_p(dir)
        FileUtils.chmod_R(0750, dir)
      end
    rescue => detail
      Puppet.log_exception(detail, "Couldn't create #{dir}: #{detail}")
    end

    ## Set a filename based on the time
    now = Time.now.gmtime
    name = %w{year month day hour min}.collect do |method|
      # Make sure we're at least two digits everywhere
      "%02d" % now.send(method).to_s
    end.join("") + ".xml"

    file = File.join(dir, name)

    begin
      ##
      ## Build the hash for the XML
      ##
      report_hash = {
        :meta => {
          :host             => self.host,
          :time             => self.time.utc.strftime("%Y-%m-%d %H:%M:%S UTC"),
          :status           => self.status,
          :puppet_version   => self.puppet_version,
          :config_version   => self.configuration_version,
          :run_type         => self.kind,
          :environment      => self.environment,
          :report_format    => self.report_format,
          :transaction_uuid => self.transaction_uuid,
        },
        :metrics            => metrics2hash(self.metrics),
        :resource_statuses  => resources2hash(self.resource_statuses),
        :logs               => logs2array(self.logs),
      }
      output = report_hash.to_xml(:root => 'PuppetReport')
      ## Write out to the report file
      Puppet::Util.replace_file(file, 0640) do |fh|
        fh.print output
      end
    rescue => detail
      Puppet.log_exception(detail, "Could not write report for #{host} at #{file}: #{detail}")
    end

  end

  ##
  ## Method to build a hash from the metrics
  ##
  def metrics2hash metrics
    h = {}
    metrics.each do |title, mtype|
      h[mtype.name] ||= {}
      mtype.values.each do |m|
        h[mtype.name].merge!({m[0].to_s => m[2]})
      end
    end
    return h
  end

  ##
  ## Method to build an array of hashes from the log entrires
  ##
  def logs2array logs
    log_array = []
    logs.each do |log|
      next if log.level == :debug

      entry = { }
      entry['level']   = log.level.to_s
      entry['message'] = log.message
      entry['source']  = log.source
      entry['file']    = log.file
      entry['tags']    = log.tags
      log_array << entry
    end
    return log_array
  end

  ##
  ## Method to build an array of hashes from the resource statuses
  ##
  def resources2hash resources
    h = []
    resources.each do |k,v|
      hash = {}
      v.instance_variables.each do |var|
        hash[var.to_s.delete("@")] = v.instance_variable_get(var)
      end
      h << hash
    end
    return h
  end
end
