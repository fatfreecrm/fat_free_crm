class Field < ActiveRecord::Base
  acts_as_list

  serialize :collection

  belongs_to :field_group

  KLASSES = [Task, Campaign, Lead, Contact, Account, Opportunity]
  KLASSES.each do |klass|
    klass.class_eval do
      def self.fields; Field.where(:klass_name => self.name).order(:position); end
      def self.core_fields; fields.where(:type => "CoreField"); end
      def self.custom_fields; fields.where(:type => "CustomField"); end
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
    'currency'    => [:decimal, {:precision => 15, :scale => 2}],
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
end
