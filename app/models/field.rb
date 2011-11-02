class Field < ActiveRecord::Base
  acts_as_list

  belongs_to :field_group

  delegate :klass, :to => :field_group

  FIELD_TYPES = {
    'short_answer' => {
      :name          => 'Short Answer',
      :column_type   => 'TEXT',
      :display_width => 200
    },
    'long_answer' => {
      :name          => 'Long Answer',
      :column_type   => 'TEXT',
      :display_width => 250
    },
    'select_list' => {
      :name          => 'Dropdown List',
      :column_type   => 'TEXT',
      :display_width => 200
    },
    'multi_select' => {
      :name          => 'Multi-select Dropdown List',
      :column_type   => 'TEXT',
      :display_width => 200
    },
    'checkbox' => {
      :name          => 'Checkbox',
      :column_type   => 'BOOLEAN'
    },
    'date' => {
      :name          => 'Date',
      :column_type   => 'DATE',
      :display_width => 100
    },
    'datetime' => {
      :name          => 'Date & Time',
      :column_type   => 'TIMESTAMP',
      :display_width => 150
    },
    'number' => {
      :name          => 'Number',
      :column_type   => 'DECIMAL',
      :display_width => 60
    }
  }

  %w(column_type display_width).each do |attr|
    class_eval %Q{
      def #{attr}
        FIELD_TYPES[field_type][:#{attr}]
      end
    }
  end

  ## Default validations for model
  #
  validates_presence_of :name, :message => "^Please enter a Field name."
  validates_format_of :name, :with => /\A[A-Za-z_]+\z/, :allow_blank => true, :message => "^Please specify Field name without any special characters or numbers, spaces are not allowed - use [A-Za-z_] "
  validates_length_of :name, :maximum => 64, :message => "^The Field name must be less than 64 characters in length."

  validates_presence_of :label, :message => "^Please enter a Field label."
  validates_length_of :label, :maximum => 64, :message => "^The Field name must be less than 64 characters in length."

  validates_numericality_of :max_size, :only_integer => true, :allow_blank => true, :message => "^Max size can only be whole number."

  validates_presence_of :field_type, :message => "^Please specify a Field type."
  validates_inclusion_of :field_type, :in => FIELD_TYPES.keys, :message => "^Hack alert::Field type Please dont change the HTML source of this application."

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20                       ; end
  def self.outline  ; "long"                   ; end
  def self.sort_by  ; "fields.created_at DESC" ; end

  SORT_BY = {
    "field name"     => "fields.name ASC",
    "field label"    => "fields.label DESC",
    "field type"     => "fields.field_type DESC",
    "max size"       => "fields.max_size DESC",
    "date created"   => "fields.created_at DESC",
    "date updated"   => "fields.updated_at DESC"
  }
end
