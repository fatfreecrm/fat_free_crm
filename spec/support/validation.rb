RSpec::Matchers.define(:have_errors_on) do |attribute|
  chain(:with_message) do |message|
    @message = message
  end

  match do |model|
    model.valid?

    @has_errors = model.errors.include?(attribute)

    if @message
      @has_errors && model.errors[attribute].include?(@message)
    else
      @has_errors
    end
  end
  
  failure_message_for_should do |model|
      if @message
        "Validation errors #{model.errors[attribute].inspect} should include #{@message.inspect}"
      else
        "#{model.class} should have errors on attribute #{attribute.inspect}"
      end
  end

  failure_message_for_should_not do |model|
    "#{model.class} should not have an error on attribute #{attribute.inspect}"
  end
end
