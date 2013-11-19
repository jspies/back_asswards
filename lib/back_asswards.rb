require "back_asswards/version"
require "back_asswards/version_check"

module BackAsswards

  def self.included(base)

  end

  @config = {
              data: "Version",
              version_field: "version",
              scope_field: "scope",
              data_storage: "ActiveRecord",
              num_versions_to_allow: 3,
              logger: Logger.new(STDOUT),
              warn: true, # traditional deprecation message,
              use_airbrake: false
            }

  @valid_config_keys = @config.keys

  def self.configure(opts = {})
    opts.each {|k,v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym}
  end

  def self.configure_with(path_to_yaml_file)
    begin
      config = YAML::load(IO.read(path_to_yaml_file))
    rescue Errno::ENOENT
      log(:warning, "YAML configuration file couldn't be found. Using defaults."); return
    rescue Psych::SyntaxError
      log(:warning, "YAML configuration file contains invalid syntax. Using defaults."); return
    end

    configure(config)
  end

  def self.config
    @config
  end

  def deprecate(versions, options = {}, &block)
    old = true
    versions = [versions] if versions.is_a?(String)
    versions = versions.to_a if versions.is_a?(Hash)

    versions.each do |version|
      vc = VersionCheck.new(version)
      old &&= vc.old?
      if BackAsswards.config[:warn]
        BackAsswards.config[:logger].warn "DEPRECATION WARNING: Version #{vc.scope} #{vc.version} #{block.source_location}"
      end
    end

    if old
      msg = "DEPRECATED CODE: #{versions} #{block.source_location}"
      BackAsswards.config[:logger].error msg
      Airbrake.notify(Exception.new(msg)) if BackAsswards.config[:use_airbrake] and Airbrake
    end
    
    yield block
  end
end
