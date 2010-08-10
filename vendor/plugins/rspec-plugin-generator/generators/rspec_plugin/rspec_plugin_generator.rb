class RspecPluginGenerator < Rails::Generator::NamedBase
  attr_reader :plugin_path, :with_database

  def initialize(runtime_args, runtime_options = {})
    @with_generator = runtime_args.delete "--with-generator"
    @with_database = runtime_args.delete "--with-database"
    super
    @plugin_path = "vendor/plugins/#{file_name}"
  end

  def manifest
    record do |m|
      m.class_collisions class_path, class_name

      m.directory "#{plugin_path}/lib"
      m.directory "#{plugin_path}/tasks"
      m.directory "#{plugin_path}/spec"

      m.template "plugin:README",       "#{plugin_path}/README"
      m.template "plugin:init.rb",      "#{plugin_path}/init.rb"
      m.template "plugin:install.rb",   "#{plugin_path}/install.rb"
      m.template "plugin:uninstall.rb", "#{plugin_path}/uninstall.rb"
      m.template "Rakefile",            "#{plugin_path}/Rakefile"
      m.template "plugin:plugin.rb",    "#{plugin_path}/lib/#{file_name}.rb"
      m.template "plugin:tasks.rake",   "#{plugin_path}/tasks/#{file_name}_tasks.rake"
      m.template "spec_helper.rb",      "#{plugin_path}/spec/spec_helper.rb"
      m.template "spec.rb",             "#{plugin_path}/spec/#{file_name}_spec.rb"

      if @with_generator
        m.directory "#{plugin_path}/generators"
        m.directory "#{plugin_path}/generators/#{file_name}"
        m.directory "#{plugin_path}/generators/#{file_name}/templates"

        m.template 'plugin:generator.rb', "#{plugin_path}/generators/#{file_name}/#{file_name}_generator.rb"
        m.template 'plugin:USAGE',        "#{plugin_path}/generators/#{file_name}/USAGE"
      end

      if @with_database
        m.directory "#{plugin_path}/spec/db"

        m.template "database.yml",  "#{plugin_path}/spec/db/database.yml"
        m.template "schema.rb",     "#{plugin_path}/spec/db/schema.rb"
      end
    end
  end
end

