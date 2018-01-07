# frozen_string_literal: true

class Module
  def alias_method_chain(target, feature)
    # Strip out punctuation on predicates, bang or writer methods since
    # e.g. target?_without_feature is not a valid method name.
    aliased_target = target.to_s.sub(/([?!=])$/, '')
    punctuation = Regexp.last_match(1)
    yield(aliased_target, punctuation) if block_given?

    with_method = "#{aliased_target}_with_#{feature}#{punctuation}"
    without_method = "#{aliased_target}_without_#{feature}#{punctuation}"

    alias_method without_method, target
    alias_method target, with_method

    if public_method_defined?(without_method)
      public target
    elsif protected_method_defined?(without_method)
      protected target
    elsif private_method_defined?(without_method)
      private target
    end
  end
end
