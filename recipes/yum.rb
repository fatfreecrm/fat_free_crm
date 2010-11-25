require 'capistrano'

# = Purpose
# yum is a Capistrano plugin module providing a set of methods
# that invoke the *yum* package manager (as used in Centos)
#
# Installs within Capistrano as the plugin _yum_.
#
# =Usage
#
#    require 'recipes/yum'
#
# Prefix all calls to the library with <tt>yum.</tt>
#
module Yum

  # Default yum command - reduces any interactivity to the minimum.
  YUM_COMMAND="yum -y"

  # Run the yum install program across the package list in 'packages'.
  # Select those packages referenced by <tt>:base</tt> and the +version+
  # of the distribution you want to use.
  def install(packages, version, options={})
    special_options = options[:repositories].collect { |repository| " --enablerepo=#{repository}"} if (options && options[:repositories].is_a?(Array))
    send(run_method, %{
      sh -c "#{YUM_COMMAND} #{special_options.to_s} install #{package_list(packages, version)}"
    }, options)
  end

  # Run a yum clean
  def clean(options={})
    send(run_method, %{sh -c "#{YUM_COMMAND} -qy clean"}, options)
  end

  # Run a yum autoclean
  def autoclean(options={})
    send(run_method, %{sh -c "#{YUM_COMMAND} -qy autoclean"}, options)
  end

  # Run a yum distribution upgrade
  def dist_upgrade(options={})
    send(run_method, %{sh -c "#{YUM_COMMAND} -qy dist-upgrade"}, options)
  end

  # Run a yum upgrade. Use dist_upgrade instead if you want to upgrade
  # the critical base packages.
  def upgrade(options={})
    send(run_method, %{sh -c "#{YUM_COMMAND} -qy upgrade"}, options)
  end

  # Run a yum update.
  def update(options={})
    send(run_method, %{sh -c "#{YUM_COMMAND} -qy update"}, options)
  end

private

  # Provides a string containing all the package names in the base
  #list plus those in +version+.
  def package_list(packages, version)
    packages[:base].to_a.join(' ') + ' ' + packages[version].to_a.join(' ')
  end

end

Capistrano.plugin :yum, Yum
