require 'spec_helper'

describe FieldGroup do
  it "should have field metadata" do
    FieldGroup.new.should respond_to(:fields)
  end
end
