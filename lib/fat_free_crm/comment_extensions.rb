module FatFreeCRM
  module CommentExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def uses_comment_extensions
        unless included_modules.include?(InstanceMethods)
          include FatFreeCRM::CommentExtensions::InstanceMethods
        end
      end
    end

    module InstanceMethods
      def add_comment_by_user(comment_body, user)
        comments.create(:comment => comment_body, :user => user) if comment_body.present?
      end
    end
  end
end

ActiveRecord::Base.send(:include, FatFreeCRM::CommentExtensions)
