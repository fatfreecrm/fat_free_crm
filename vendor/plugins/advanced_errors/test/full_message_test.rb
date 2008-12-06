require File.dirname(__FILE__) + File::SEPARATOR + 'test_helper'

class AdvancedErrorsTest < Test::Unit::TestCase
  include ErrorHelper
  
  def test_should_render_errors
    @user = User.new({:login => 'blah'})
    assert !@user.valid?, 'User should be invalid'
    assert @user.errors.size == 1, 'There should only be one error.'
    assert !@user.errors.on(:password).blank?, 'They should be a failed validations on :password'
    assert @user.errors.full_messages.first == "Password can't be blank", "The message is wrong."
    expected_error_message = %Q{
      <div class="errorExplanation" id="errorExplanation">
        <h2>1 error prohibited this user from being saved</h2>
        <p>There were problems with the following fields:</p>
        <ul>
          <li>Password can't be blank</li>
        </ul>
      </div>
    }.normalize_html
    actual_error_message = error_messages_for(:user).normalize_html
    assert expected_error_message == actual_error_message, 'Expected and actual messages should be the same'
    @user = nil
  end
  
  def test_should_not_display_attribute_if_caret_is_first_charactor
    @user = User.new({:password => 'blah'})
    assert !@user.valid?, 'User should be invalid'
    assert @user.errors.size == 1, 'There should only be one error.'
    assert !@user.errors.on(:login).blank?, 'They should be a failed validations on :login'
    assert @user.errors.full_messages.first == 'You really should have a login.', "The message is wrong."
    expected_error_message = %Q{
      <div class="errorExplanation" id="errorExplanation">
        <h2>1 error prohibited this user from being saved</h2>
        <p>There were problems with the following fields:</p>
        <ul>
          <li>You really should have a login.</li>
        </ul>
      </div>
    }.normalize_html
    actual_error_message = error_messages_for(:user).normalize_html
    assert expected_error_message == actual_error_message, 'Expected and actual messages should be the same'
    @user = nil
  end
end