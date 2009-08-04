module ActsAsCommentable
  # including this module into your Comment model will give you finders and named scopes
  # useful for working with Comments.
  # The named scopes are:
  #   in_order: Returns comments in the order they were created (created_at ASC).
  #   recent: Returns comments by how recently they were created (created_at DESC).
  #   limit(N): Return no more than N comments.
  module Comment
    
    def self.included(comment_model)
      comment_model.extend Finders
      comment_model.named_scope :in_order, {:order => 'created_at ASC'}
      comment_model.named_scope :recent, {:order => "created_at DESC"}
      comment_model.named_scope :limit, lambda {|limit| {:limit => limit}}
    end
    
    module Finders
      # Helper class method to lookup all comments assigned
      # to all commentable types for a given user.
      def find_comments_by_user(user)
        find(:all,
          :conditions => ["user_id = ?", user.id],
          :order => "created_at DESC"
        )
      end

      # Helper class method to look up all comments for 
      # commentable class name and commentable id.
      def find_comments_for_commentable(commentable_str, commentable_id)
        find(:all,
          :conditions => ["commentable_type = ? and commentable_id = ?", commentable_str, commentable_id],
          :order => "created_at DESC"
        )
      end

      # Helper class method to look up a commentable object
      # given the commentable class name and id 
      def find_commentable(commentable_str, commentable_id)
        commentable_str.constantize.find(commentable_id)
      end
    end
  end
end