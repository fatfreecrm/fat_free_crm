require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do

  def mock_comment(stubs={})
    @mock_comment ||= mock_model(Comment, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all comments as @comments" do
      Comment.should_receive(:find).with(:all).and_return([mock_comment])
      get :index
      assigns[:comments].should == [mock_comment]
    end

    describe "with mime type of xml" do
  
      it "should render all comments as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Comment.should_receive(:find).with(:all).and_return(comments = mock("Array of Comments"))
        comments.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested comment as @comment" do
      Comment.should_receive(:find).with("37").and_return(mock_comment)
      get :show, :id => "37"
      assigns[:comment].should equal(mock_comment)
    end
    
    describe "with mime type of xml" do

      it "should render the requested comment as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Comment.should_receive(:find).with("37").and_return(mock_comment)
        mock_comment.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new comment as @comment" do
      Comment.should_receive(:new).and_return(mock_comment)
      get :new
      assigns[:comment].should equal(mock_comment)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested comment as @comment" do
      Comment.should_receive(:find).with("37").and_return(mock_comment)
      get :edit, :id => "37"
      assigns[:comment].should equal(mock_comment)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created comment as @comment" do
        Comment.should_receive(:new).with({'these' => 'params'}).and_return(mock_comment(:save => true))
        post :create, :comment => {:these => 'params'}
        assigns(:comment).should equal(mock_comment)
      end

      it "should redirect to the created comment" do
        Comment.stub!(:new).and_return(mock_comment(:save => true))
        post :create, :comment => {}
        response.should redirect_to(comment_url(mock_comment))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved comment as @comment" do
        Comment.stub!(:new).with({'these' => 'params'}).and_return(mock_comment(:save => false))
        post :create, :comment => {:these => 'params'}
        assigns(:comment).should equal(mock_comment)
      end

      it "should re-render the 'new' template" do
        Comment.stub!(:new).and_return(mock_comment(:save => false))
        post :create, :comment => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested comment" do
        Comment.should_receive(:find).with("37").and_return(mock_comment)
        mock_comment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :comment => {:these => 'params'}
      end

      it "should expose the requested comment as @comment" do
        Comment.stub!(:find).and_return(mock_comment(:update_attributes => true))
        put :update, :id => "1"
        assigns(:comment).should equal(mock_comment)
      end

      it "should redirect to the comment" do
        Comment.stub!(:find).and_return(mock_comment(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(comment_url(mock_comment))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested comment" do
        Comment.should_receive(:find).with("37").and_return(mock_comment)
        mock_comment.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :comment => {:these => 'params'}
      end

      it "should expose the comment as @comment" do
        Comment.stub!(:find).and_return(mock_comment(:update_attributes => false))
        put :update, :id => "1"
        assigns(:comment).should equal(mock_comment)
      end

      it "should re-render the 'edit' template" do
        Comment.stub!(:find).and_return(mock_comment(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested comment" do
      Comment.should_receive(:find).with("37").and_return(mock_comment)
      mock_comment.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the comments list" do
      Comment.stub!(:find).and_return(mock_comment(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(comments_url)
    end

  end

end
