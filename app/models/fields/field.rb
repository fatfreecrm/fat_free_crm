class Field < ActiveRecord::Base
  acts_as_list

  serialize :collection

  belongs_to :field_group

  KLASSES = %w(Task Campaign Lead Contact Account Opportunity).map(&:constantize)
  KLASSES.each do |klass|
    klass.class_eval do
      def self.fields(field_type = "CoreField")
        Field.where(:klass_name => self.name, :type => field_type)
      end
      def self.custom_fields; fields("CustomField"); end
    end
  end

  FIELD_TYPES = {
    'string'      => :string,
    'text'        => :text,
    'email'       => :string,
    'url'         => :string,
    'tel'         => :string,
    'select'      => :string,
    'radio'       => :string,
    'checkboxes'  => :text,
    'multiselect' => :text,
    'checkbox'    => :boolean,
    'date'        => :date,
    'datetime'    => :timestamp,
    'currency'    => [:decimal, {:scale => 2}],
    'integer'     => :integer,
    'float'       => :float
  }

  def self.field_types
    # Expands concise FIELD_TYPES into a more usable hash
    @field_types ||= FIELD_TYPES.inject({}) do |hash, n|
      arr = [n[1]].flatten
      hash[n[0]] = {:type => arr[0], :options => arr[1]}
      hash
    end
  end

  def column_type(field_type = self.as)
    (opts = Field.field_types[field_type]) ? opts[:type] : raise("Unknown field_type: #{field_type}")
  end

  def input_options
    attributes.reject { |k,v|
      %w(type field_group position maxlength).include?(k)
    }.merge(:input_html => {:maxlength => attributes[:maxlength]})
  end

  ## Default validations for model
  #
  validates_presence_of :label, :message => "^Please enter a Field label."
  validates_length_of :label, :maximum => 64, :message => "^The Field name must be less than 64 characters in length."

  validates_numericality_of :maxlength, :only_integer => true, :allow_blank => true, :message => "^Max size can only be whole number."

  validates_presence_of :as, :message => "^Please specify a Field type."
  validates_inclusion_of :as, :in => FIELD_TYPES.keys, :message => "Invalid Field Type."

  def klass
    klass_name.constantize
  end

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
