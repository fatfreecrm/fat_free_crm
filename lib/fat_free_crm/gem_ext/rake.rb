if defined?(Rake)
  module Rake
    def self.remove_task(task_name)
      Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)
    end
  end
end
