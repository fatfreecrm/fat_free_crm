# Fat Free CRM
# Copyright (C) 2008-2009 by Michael Dvorkin
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
# Schema version: 23
#
# Table name: customfields
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  tag_id               :integer(4)
#  field_name,          :string(64)
#  field_type,          :string(32)
#  field_label,         :string(64)
#  table_name,          :string(32)
#  display_sequence,    :integer(4)
#  display_block,       :integer(4)
#  display_width,       :integer(4)
#  max_size,            :integer(4)
#  disabled,            :boolean
#  required,            :boolean
#  created_at           :datetime
#  updated_at           :datetime
#

class CustomField < Field
  acts_as_list

  before_validation :set_defaults, :on => :create

  FIELD_TYPES = %w[INTEGER BOOLEAN DECIMAL FLOAT VARCHAR(255) DATE TIMESTAMP TEXT]

  ## Default validations for model
  #
  validates_presence_of :field_name, :message => "^Please enter a Field name."
  validates_format_of :field_name, :with => /\A[A-Za-z_]+\z/, :allow_blank => true, :message => "^Please specify Field name without any special characters or numbers, spaces are not allowed - use [A-Za-z_] "
  validates_length_of :field_name, :maximum => 64, :message => "^The Field name must be less than 64 characters in length."
  validates_uniqueness_of :field_name, :scope => :tag_id, :message => "^The field name must be unique."

  validates_presence_of :field_label, :message => "^Please enter a Field label."
  validates_length_of :field_label, :maximum => 64, :message => "^The Field name must be less than 64 characters in length."

  validates_presence_of :field_type, :message => "^Please specify a Field type."
  validates_inclusion_of :field_type, :in => FIELD_TYPES, :message => "^Hack alert::Field type Please dont change the HTML source of this application."

  validates_presence_of :display_width, :message => "^Please enter a Width."

  validates_numericality_of :display_width, :only_integer => true, :allow_blank => true, :message => "^Width can only be whole number."
  validates_numericality_of :max_size, :only_integer => true, :allow_blank => true, :message => "^Max size can only be whole number."

  SORT_BY = {
    "field name"         => "customfields.field_name ASC",
    "field label"        => "customfields.field_label DESC",
    "field type"         => "customfields.field_type DESC",
    "table"              => "customfields.table_name DESC",
    "display width"      => "customfields.display_width DESC",
    "max size"           => "customfields.max_size DESC",
    "date created"       => "customfields.created_at DESC",
    "date updated"       => "customfields.updated_at DESC"
  }

  after_create :add_column
  after_validation :update_column, :on => :update

  def set_defaults
    self.display_width ||= 220
    if self.field_name.blank? and self.field_label
      column_name = self.field_label.underscore.gsub(/[_ ]+/,'_').gsub(/[^a-z0-9_]/,'')
      column_name << "_customfield" if self.respond_to?(column_name)
      self.field_name = column_name
    end
  end

  def add_column
    unless tag_class.columns.map(&:name).include?(self.field_name)
      connection.add_column(self.table_name, self.field_name, self.field_type)
      tag_class.reset_column_information
    end
  end

  def update_column
    if self.errors.empty?
      if self.field_name_changed?
        connection.rename_column(self.table_name, self.field_name_was, self.field_name)
      end

      if self.required_changed? || self.field_name_changed?
        Object.send(:remove_const, tag_class_name.to_sym)
      end
    end
  end

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20                             ; end
  def self.outline  ; "long"                         ; end
  def self.sort_by  ; "customfields.created_at DESC" ; end

  #----------------------------------------------------------------------------
  def name
    self.field_name
  end

  # Handle 'form_field_type=' to allow a specific set of form field types from a hash
  #----------------------------------------------------------------------------
  def form_field_type=(macro)
    if Customfield.form_field_types[macro]
      self.update_attributes(Customfield.form_field_types[macro][:attributes])
    end
    super
  end

  def display_value(tag_table_object)
    if tag_table_object
      value = tag_table_object.send(self.field_name)
      case form_field_type
      when "checkbox"
        value == 0 ? "no" : "yes"
      when 'date'
        value && value.strftime("%d/%m/%Y")
      when 'datetime'
        value && value.strftime("%d/%m/%Y %h:%m")
      when 'multi_select'
        # Comma separated, 2 per line.
        (value.is_a?(Array) ? value : [value]).in_groups_of(2).map{|g| g[1] ? g.join(", ") : g[0] }.join('<br/>').html_safe
      else
        value.to_s
      end
    end
  end
end

