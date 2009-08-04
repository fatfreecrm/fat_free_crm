class CommentGenerator < Rails::Generator::Base
   def manifest
     record do |m|
       m.directory 'app/models'
       m.file 'comment.rb', 'app/models/comment.rb'
       m.migration_template "create_comments.rb", "db/migrate"
     end
   end
   # ick what a hack.
   def file_name
     "create_comments"
   end
 end
