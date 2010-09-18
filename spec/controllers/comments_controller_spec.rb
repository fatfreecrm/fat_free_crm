require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do

  COMMENTABLE = [ :account, :campaign, :contact, :lead, :opportunity ].freeze

  before(:each) do
    require_user
  end

  # GET /comments
  # GET /comments.xml
  #----------------------------------------------------------------------------
  describe "responding to GET index" do
    COMMENTABLE.each do |asset|
      describe "(HTML)" do
        before(:each) do
          @asset = Factory(asset)
        end

        it "should redirect to the asset landing page if the asset is found" do
          get :index, :"#{asset}_id" => @asset.id
          response.should redirect_to(:controller => asset.to_s.pluralize, :action => :show, :id => @asset.id)
        end

        it "should redirect to root url with warning if the asset is not found" do
          get :index, :"#{asset}_id" => @asset.id + 42
          flash[:warning].should_not == nil
          response.should redirect_to(root_path)
        end
      end # HTML

      describe "(XML)" do
        before(:each) do
          @asset = Factory(asset)
          @asset.comments = [ Factory(:comment, :commentable => @asset) ]
          request.env["HTTP_ACCEPT"] = "application/xml"
        end

        it "should render all comments as XML if the asset is found found" do
          get :index, :"#{asset}_id" => @asset.id
          response.body.should == @asset.comments.to_xml
        end

        it "XML: should return 404 (Not Found) XML error if the asset is not found" do
          get :index, :"#{asset}_id" => @asset.id + 42
          flash[:warning].should_not == nil
          response.code.should == "404"
        end
      end # XML
    end # COMMENTABLE.each

  end

  # GET /comments/1
  # GET /comments/1.xml                                         not implemented
  #----------------------------------------------------------------------------
  # describe "responding to GET show" do
  #
  #   it "should expose the requested comment as @comment" do
  #     Comment.should_receive(:find).with("37").and_return(mock_comment)
  #     get :show, :id => "37"
  #     assigns[:comment].should equal(mock_comment)
  #   end
  #
  #   describe "with mime type of xml" do
  #     it "should render the requested comment as xml" do
  #       request.env["HTTP_ACCEPT"] = "application/xml"
  #       Comment.should_receive(:find).with("37").and_return(mock_comment)
  #       mock_comment.should_receive(:to_xml).and_return("generated XML")
  #       get :show, :id => "37"
  #       response.body.should == "generated XML"
  #     end
  #   end
  #
  # end

  # GET /comments/new
  # GET /comments/new.xml                                                  AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET new" do

    COMMENTABLE.each do |asset|
      it "should expose a new comment as @comment for #{asset}" do
        @asset = Factory(asset)
        @comment = Comment.new

        xhr :get, :new, "#{asset}_id".to_sym => @asset.id
        assigns[:comment].attributes.should == @comment.attributes
        assigns[:commentable].should == asset.to_s
        response.should render_template("comments/new")
      end

      it "should save the fact that a comment gets added to #{asset}" do
        @asset = Factory(asset)
        @comment = Comment.new

        xhr :get, :new, "#{asset}_id".to_sym => @asset.id
        session["#{asset}_new_comment"].should == true
      end

      it "should clear the session if user cancels a comment for #{asset}" do
        @asset = Factory(asset)
        @comment = Comment.new

        xhr :get, :new, "#{asset}_id".to_sym => @asset.id, :cancel => "true"
        session["#{asset}_new_comment"].should == nil
      end

      it "should redirect to #{asset}'s index page with the message if the #{asset} got deleted" do
        @asset = Factory(asset)
        @asset.destroy
        @comment = Comment.new

        xhr :get, :new, "#{asset}_id".to_sym => @asset.id
        flash[:warning].should_not == nil
        response.body.should =~ %r(window.location.href)m
        response.body.should =~ %r(#{asset.to_s.pluralize})m
      end

      it "should redirect to #{asset}'s index page with the message if the #{asset} got protected" do
        @asset = Factory(asset, :access => "Private")
        @comment = Comment.new

        xhr :get, :new, "#{asset}_id".to_sym => @asset.id
        flash[:warning].should_not == nil
        response.body.should =~ %r(window.location.href)m
        response.body.should =~ %r(#{asset.to_s.pluralize})m
      end
    end
  end

  # GET /comments/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  describe "responding to GET edit" do

    COMMENTABLE.each do |asset|
      it "should expose the requested comment as @commment and render [edit] template" do
        @asset = Factory(asset)
        @comment = Factory(:comment, :id => 42, :commentable => @asset, :user => @current_user)
        Comment.stub!(:new).and_return(@comment)

        xhr :get, :edit, :id => 42
        assigns[:comment].should == @comment
        response.should render_template("comments/edit")
      end
    end

  end

  # POST /comments
  # POST /comments.xml                                                     AJAX
  #----------------------------------------------------------------------------
  describe "responding to POST create" do

    describe "with valid params" do
      COMMENTABLE.each do |asset|
        it "should expose a newly created comment as @comment for the #{asset}" do
          @asset = Factory(asset)
          @comment = Factory.build(:comment, :commentable => @asset, :user => @current_user)
          Comment.stub!(:new).and_return(@comment)

          xhr :post, :create, :comment => { :commentable_type => asset.to_s.classify, :commentable_id => @asset.id, :user_id => @current_user.id, :comment => "Hello" }
          assigns[:comment].should == @comment
          response.should render_template("comments/create")
        end
      end
    end

    describe "with invalid params" do
      COMMENTABLE.each do |asset|
        it "should expose a newly created but unsaved comment as @comment for #{asset}" do
          @asset = Factory(asset)
          @comment = Factory.build(:comment, :commentable => @asset, :user => @current_user)
          Comment.stub!(:new).and_return(@comment)

          xhr :post, :create, :comment => {}
          assigns[:comment].should == @comment
          response.should render_template("comments/create")
        end
      end
    end

  end

  # PUT /comments/1
  # PUT /comments/1.xml                                          not implemened
  #----------------------------------------------------------------------------
  # describe "responding to PUT udpate" do
  #
  #   describe "with valid params" do
  #     it "should update the requested comment" do
  #       Comment.should_receive(:find).with("37").and_return(mock_comment)
  #       mock_comment.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :comment => {:these => 'params'}
  #     end
  #
  #     it "should expose the requested comment as @comment" do
  #       Comment.stub!(:find).and_return(mock_comment(:update_attributes => true))
  #       put :update, :id => "1"
  #       assigns(:comment).should equal(mock_comment)
  #     end
  #
  #     it "should redirect to the comment" do
  #       Comment.stub!(:find).and_return(mock_comment(:update_attributes => true))
  #       put :update, :id => "1"
  #       response.should redirect_to(comment_path(mock_comment))
  #     end
  #   end
  #
  #   describe "with invalid params" do
  #     it "should update the requested comment" do
  #       Comment.should_receive(:find).with("37").and_return(mock_comment)
  #       mock_comment.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :comment => {:these => 'params'}
  #     end
  #
  #     it "should expose the comment as @comment" do
  #       Comment.stub!(:find).and_return(mock_comment(:update_attributes => false))
  #       put :update, :id => "1"
  #       assigns(:comment).should equal(mock_comment)
  #     end
  #
  #     it "should re-render the 'edit' template" do
  #       Comment.stub!(:find).and_return(mock_comment(:update_attributes => false))
  #       put :update, :id => "1"
  #       response.should render_template('edit')
  #     end
  #   end
  #
  # end

  # DELETE /comments/1
  # DELETE /comments/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  describe "responding to DELETE destroy" do
    describe "AJAX request" do
      describe "with valid params" do
        COMMENTABLE.each do |asset|
          it "should destroy the requested comment and render [destroy] template" do
            @asset = Factory(asset)
            @comment = Factory.create(:comment, :commentable => @asset, :user => @current_user)
            Comment.stub!(:new).and_return(@comment)

            xhr :delete, :destroy, :id => @comment.id
            lambda { Comment.find(@comment) }.should raise_error(ActiveRecord::RecordNotFound)
            response.should render_template("comments/destroy")
          end
        end
      end
    end
  end

end
