require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'action_view'
require File.dirname(__FILE__) + '/../rails/init'

ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('sqlite3')

ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.boolean :admin,    :default => false
    t.string  :login,    :default => ''
    t.string  :password, :default => ''
  end
  
  create_table :accounts do |t|
    t.string :subdomain, :default => ''
    t.string :title,     :default => ''
  end
  
  create_table :emails do |t|
    t.references :user_id
    t.string :email_address
    t.string :preferred_type
  end
end

class User < ActiveRecord::Base
  has_many :emails
  validates_presence_of :login, :message => "^You really should have a login."
  validates_presence_of :password
  attr_accessible :login, :password
end

class Email < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user, :email_address
  validates_inclusion_of :preferred_type, :in => ['html', 'plain text']
  attr_accessible :email_address
end

class Account < ActiveRecord::Base; end

class String
  def colapse_whitespace
    gsub(/\s+/, ' ')
  end
  
  def remove_unnessisary_spaces_from_html
    gsub(/>\s+</, '><')
  end
  
  def normalize_html
    colapse_whitespace.remove_unnessisary_spaces_from_html.strip
  end
end

module ErrorHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveRecordHelper
end