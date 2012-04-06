require 'cancan'

# Setup
# =====
#
# Put this gist in Rails.root/config/initializers/cancan.rb
# Add Squeel to Gemfile, see https://github.com/ernie/squeel
#
#     gem "squeel", "~> 0.9.3"
#
# Load Squeel hash and symbol extensions in squeel config initializer
#
#     Squeel.configure do |config|
#       config.load_core_extensions :hash, :symbol
#     end
#
# then you can write
#
#    can :manage, User, :permissions.outer => {:type.matches => 'Manage%'}}
#
# This should offer all the old MetaWhere capabilities,
# and extra, also allows outer joins
#
# you might also be interested in https://gist.github.com/1012332
# if you use MetaWhere

# https://gist.github.com/1523940
class String
  include Squeel::Nodes::PredicateOperators
end

module Squeel
  module Visitors
    class PredicateVisitor < Visitor
      def visit_String(o, parent)
        Arel::Nodes::SqlLiteral.new(o)
      end
    end
  end
end

module CanCan

  module ModelAdapters
    class ActiveRecordAdapter < AbstractAdapter

      def self.override_condition_matching?(subject, name, value)
        name.kind_of?(Squeel::Nodes::Predicate) if defined? Squeel
      end

      def self.matches_condition?(subject, name, value)
        subject_value = subject.send(name.expr)
        method_name = name.method_name.to_s
        if method_name.ends_with? "_any"
          value.any? { |v| squeel_match? subject_value, method_name.sub("_any", ""), v }
        elsif method_name.ends_with? "_all"
          value.all? { |v| squeel_match? subject_value, method_name.sub("_all", ""), v }
        else
          squeel_match? subject_value, name.method_name, value
        end
      end

      def self.squeel_match?(subject_value, method, value)
        case method.to_sym
        when :eq      then subject_value == value
        when :not_eq  then subject_value != value
        when :in      then value.include?(subject_value)
        when :not_in  then !value.include?(subject_value)
        when :lt      then subject_value < value
        when :lteq    then subject_value <= value
        when :gt      then subject_value > value
        when :gteq    then subject_value >= value
        when :matches then subject_value =~ Regexp.new("^" + Regexp.escape(value).gsub("%", ".*") + "$", true)
        when :does_not_match then !squeel_match?(subject_value, :matches, value)
        else raise NotImplemented, "The #{method} Squeel condition is not supported."
        end
      end

      # mostly let Squeel do the job in building the query
      def conditions
        if @rules.size == 1 && @rules.first.base_behavior
          # Return the conditions directly if there's just one definition
          @rules.first.conditions.dup
        else
          @rules.reverse.inject(false_sql) do |accumulator, rule|
            conditions = rule.conditions.dup
            if conditions.blank?
              rule.base_behavior ? (accumulator | true_sql) : (accumulator & false_sql)
            else
              rule.base_behavior ? (accumulator | conditions) : (accumulator & -conditions)
            end
          end
        end
      end

      private

      # override to fix overwrites
      # do not write existing hashes using empty hashes
      def merge_joins(base, add)
        add.each do |name, nested|
          if base[name].is_a?(Hash) && nested.present?
            merge_joins(base[name], nested)
          elsif !base[name].is_a?(Hash) || nested.present?
            base[name] = nested
          end
        end
      end

    end
  end

  class Rule
    # allow Squeel
    def matches_conditions_hash?(subject, conditions = @conditions)
      if conditions.empty?
        true
      else
        if model_adapter(subject).override_conditions_hash_matching? subject, conditions
          model_adapter(subject).matches_conditions_hash? subject, conditions
        else
          conditions.all? do |name, value|
            if model_adapter(subject).override_condition_matching? subject, name, value
              model_adapter(subject).matches_condition? subject, name, value
            else
              method_name = case name
              when Symbol                   then name
              when Squeel::Nodes::Join      then name._name
              when Squeel::Nodes::Predicate then name.expr
              else raise name
              end
              attribute = subject.send(method_name)
              if value.kind_of?(Hash)
                if attribute.kind_of? Array
                  attribute.any? { |element| matches_conditions_hash? element, value }
                else
                  !attribute.nil? && matches_conditions_hash?(attribute, value)
                end
              elsif value.kind_of?(Array) || value.kind_of?(Range)
                value.include? attribute
              else
                attribute == value
              end
            end
          end
        end
      end
    end
  end

end
