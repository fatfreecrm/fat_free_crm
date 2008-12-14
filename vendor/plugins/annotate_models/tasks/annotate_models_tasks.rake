desc "Add schema information (as comments) to model files"

task :annotate_models do
   require File.join(File.dirname(__FILE__), "../lib/annotate_models.rb")
   AnnotateModels.do_annotations
end