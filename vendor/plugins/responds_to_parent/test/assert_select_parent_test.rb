require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test/unit'
require 'test_help'

class AssertSelectParentTest < Test::Unit::TestCase
  class AssertSelectParentController < ActionController::Base
    def response_with=(content)
      @content = content
    end

    def response_with(&block)
      @update = block
    end

    def rjs
      responds_to_parent do
        render :update do |page|
          @update.call page
        end
      end
      @update = nil
    end

    def text
      responds_to_parent do
        render :text => @content, :layout => false
      end
      @content = nil
    end

    def not_respond_to_parent
      render :nothing => true
    end

    def rescue_action(e)
       raise e
    end
  end

  def setup
    @controller = AssertSelectParentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_basic
    render_rjs do |page|
      page.replace "test", "<div id=\"1\">foo</div>"
    end

    found = false
    assert_select_parent do
      assert_select_rjs do
        assert_select "#1"
        found = true
      end
    end
    assert found
  end

  def test_bubble_up_failure
    render_rjs do |page|
      page.replace "test", "<div id=\"1\">foo</div>"
    end

    assert_raise(Test::Unit::AssertionFailedError) do
      assert_select_parent do
        assert_select_rjs do
          assert_select "#nonexistent"
        end
      end
    end
  end

  def test_fail_if_no_content_for_parent
    get :not_respond_to_parent
    assert_raise(Test::Unit::AssertionFailedError) { assert_select_parent }
  end

  def test_quotes
    do_test_with_text %(single' double" escaped\\' escaped\\" doubleescaped\\\\\\' doubleescaped\\\\\\")
  end

  def test_new_line
    do_test_with_text "line1\nline2\\nline2\\\nline3\\\\nline3\\\\\nline4\\\\\\nline4"
  end

  protected
    def render_rjs(&block)
      @controller.response_with &block
      get :rjs
    end

    def render_text(text)
      @controller.response_with = text
      get :text
    end

    def do_test_with_text(text)
      render_text text

      assert_select_parent do |text_for_parent|
        assert_equal text, text_for_parent
      end
    end
end
require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test/unit'
require 'test_help'

class AssertSelectParentTest < Test::Unit::TestCase
  class AssertSelectParentController < ActionController::Base
    def response_with=(content)
      @content = content
    end

    def response_with(&block)
      @update = block
    end

    def rjs
      responds_to_parent do
        render :update do |page|
          @update.call page
        end
      end
      @update = nil
    end

    def text
      responds_to_parent do
        render :text => @content, :layout => false
      end
      @content = nil
    end

    def not_respond_to_parent
      render :nothing => true
    end

    def rescue_action(e)
       raise e
    end
  end

  def setup
    @controller = AssertSelectParentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_basic
    render_rjs do |page|
      page.replace "test", "<div id=\"1\">foo</div>"
    end

    found = false
    assert_select_parent do
      assert_select_rjs do
        assert_select "#1"
        found = true
      end
    end
    assert found
  end

  def test_bubble_up_failure
    render_rjs do |page|
      page.replace "test", "<div id=\"1\">foo</div>"
    end

    assert_raise(Test::Unit::AssertionFailedError) do
      assert_select_parent do
        assert_select_rjs do
          assert_select "#nonexistent"
        end
      end
    end
  end

  def test_fail_if_no_content_for_parent
    get :not_respond_to_parent
    assert_raise(Test::Unit::AssertionFailedError) { assert_select_parent }
  end

  def test_quotes
    do_test_with_text %(single' double" escaped\\' escaped\\" doubleescaped\\\\\\' doubleescaped\\\\\\")
  end

  def test_new_line
    do_test_with_text "line1\nline2\\nline2\\\nline3\\\\nline3\\\\\nline4\\\\\\nline4"
  end

  protected
    def render_rjs(&block)
      @controller.response_with &block
      get :rjs
    end

    def render_text(text)
      @controller.response_with = text
      get :text
    end

    def do_test_with_text(text)
      render_text text

      assert_select_parent do |text_for_parent|
        assert_equal text, text_for_parent
      end
    end
end
require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test/unit'
require 'test_help'

class AssertSelectParentTest < Test::Unit::TestCase
  class AssertSelectParentController < ActionController::Base
    def response_with=(content)
      @content = content
    end

    def response_with(&block)
      @update = block
    end

    def rjs
      responds_to_parent do
        render :update do |page|
          @update.call page
        end
      end
      @update = nil
    end

    def text
      responds_to_parent do
        render :text => @content, :layout => false
      end
      @content = nil
    end

    def not_respond_to_parent
      render :nothing => true
    end

    def rescue_action(e)
       raise e
    end
  end

  def setup
    @controller = AssertSelectParentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_basic
    render_rjs do |page|
      page.replace "test", "<div id=\"1\">foo</div>"
    end

    found = false
    assert_select_parent do
      assert_select_rjs do
        assert_select "#1"
        found = true
      end
    end
    assert found
  end

  def test_bubble_up_failure
    render_rjs do |page|
      page.replace "test", "<div id=\"1\">foo</div>"
    end

    assert_raise(Test::Unit::AssertionFailedError) do
      assert_select_parent do
        assert_select_rjs do
          assert_select "#nonexistent"
        end
      end
    end
  end

  def test_fail_if_no_content_for_parent
    get :not_respond_to_parent
    assert_raise(Test::Unit::AssertionFailedError) { assert_select_parent }
  end

  def test_quotes
    do_test_with_text %(single' double" escaped\\' escaped\\" doubleescaped\\\\\\' doubleescaped\\\\\\")
  end

  def test_new_line
    do_test_with_text "line1\nline2\\nline2\\\nline3\\\\nline3\\\\\nline4\\\\\\nline4"
  end

  protected
    def render_rjs(&block)
      @controller.response_with &block
      get :rjs
    end

    def render_text(text)
      @controller.response_with = text
      get :text
    end

    def do_test_with_text(text)
      render_text text

      assert_select_parent do |text_for_parent|
        assert_equal text, text_for_parent
      end
    end
end
