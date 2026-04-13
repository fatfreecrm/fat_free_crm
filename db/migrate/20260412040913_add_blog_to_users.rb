# frozen_string_literal: true

class AddBlogToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :blog, :string, limit: 128
  end
end
