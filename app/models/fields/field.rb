# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

# == Schema Information
#
# Table name: fields
#
#  id             :integer         not null, primary key
#  type           :string(255)
#  field_group_id :integer
#  position       :integer
#  pair_id        :integer
#  name           :string(64)
#  label          :string(128)
#  hint           :string(255)
#  placeholder    :string(255)
#  as             :string(32)
#  collection     :text
#  disabled       :boolean
#  required       :boolean
#  maxlength      :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class Field < ActiveRecord::Base
  acts_as_list

  serialize :collection, Array
  serialize :settings, HashWithIndifferentAccess

  belongs_to :field_group
  
  scope :core_fields, where(:type => 'CoreField')
  scope :custom_fields, where("type != 'CoreField'")
  scope :without_pairs, where(:pair_id => nil)

  delegate :klass, :klass_name, :klass_name=, :to => :field_group

  BASE_FIELD_TYPES = {
    'string'      => {:klass => 'CustomField', :type => 'string'},
    'text'        => {:klass => 'CustomField', :type => 'text'},
    'email'       => {:klass => 'CustomField', :type => 'string'},
    'url'         => {:klass => 'CustomField', :type => 'string'},
    'tel'         => {:klass => 'CustomField', :type => 'string'},
    'select'      => {:klass => 'CustomField', :type => 'string'},
    'radio'       => {:klass => 'CustomField', :type => 'string'},
    'check_boxes' => {:klass => 'CustomField', :type => 'text'},
    'boolean'     => {:klass => 'CustomField', :type => 'boolean'},
    'date'        => {:klass => 'CustomField', :type => 'date'},
    'datetime'    => {:klass => 'CustomField', :type => 'timestamp'},
    'decimal'     => {:klass => 'CustomField', :type => 'decimal', :column_options => {:precision => 15, :scale => 2} },
    'integer'     => {:klass => 'CustomField', :type => 'integer'},
    'float'       => {:klass => 'CustomField', :type => 'float'}
  }.with_indifferent_access

  validates_presence_of :label, :message => "^Please enter a field label."
  validates_length_of :label, :maximum => 64, :message => "^The field name must be less than 64 characters in length."
  validates_numericality_of :maxlength, :only_integer => true, :allow_blank => true, :message => "^Max size can only be whole number."
  validates_presence_of :as, :message => "^Please specify a field type."
  validates_inclusion_of :as, :in => Proc.new{self.field_types.keys}, :message => "^Invalid field type.", :allow_blank => true

  def column_type(field_type = self.as)
    (opts = Field.field_types[field_type]) ? opts[:type] : raise("Unknown field_type: #{field_type}")
  end

  def input_options
    input_html = {}
    attributes.reject { |k,v|
      !%w(as collection disabled label placeholder required maxlength).include?(k) or v.blank?
    }.symbolize_keys.merge(input_html)
  end

  def collection_string=(value)
    self.collection = value.split("|").map(&:strip).reject(&:blank?)
  end
  def collection_string
    collection.try(:join, "|")
  end

  def render_value(object)
    render object.send(name)
  end

  def render(value)
    case as
    when 'checkbox'
      value.to_s == '0' ? "no" : "yes"
    when 'date'
      value && value.strftime(I18n.t("date.formats.mmddyy"))
    when 'datetime'
      value && value.strftime(I18n.t("time.formats.mmddhhss"))
    when 'check_boxes'
      value.select(&:present?).in_groups_of(2, false).map {|g| g.join(', ')}.join("<br />".html_safe) if Array === value
    else
      value.to_s
    end
  end

  protected

  class << self

    # Provides access to registered field_types
    #------------------------------------------------------------------------------
    def field_types
      @@field_types ||= BASE_FIELD_TYPES
    end

    # Register custom fields so they are available to the rest of the app
    # Example options: :as => 'datepair', :type => 'date', :klass => 'CustomFieldDatePair'
    #------------------------------------------------------------------------------
    def register(options)
      opts = options.dup
      as = options.delete(:as)
      (@@field_types ||= BASE_FIELD_TYPES).merge!(as => options)
    end

    # Returns class name given a key
    #------------------------------------------------------------------------------
    def lookup_class(as)
      (@@field_types ||= BASE_FIELD_TYPES)[as][:klass]
    end

  end

end
