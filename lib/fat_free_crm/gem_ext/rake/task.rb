module Rake
  Task.class_eval do   
    # Removes a Rake task
    def self.remove(task_name)
      Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)
    end
  end
end
