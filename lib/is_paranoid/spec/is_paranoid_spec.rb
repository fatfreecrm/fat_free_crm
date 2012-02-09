require 'spec_helper'

class Person < ActiveRecord::Base
  has_many :androids, :foreign_key => :owner_id, :dependent => :destroy
end

class Android < ActiveRecord::Base
  validates_uniqueness_of :name
  is_paranoid
  scope :ordered, :order => 'name DESC'
  scope :r2d2, :conditions => { :name => 'R2D2' }
  scope :c3p0, :conditions => { :name => 'C3P0' }
end

class AndroidObserver < ActiveRecord::Observer
  observe Android
  @@destroy_count = 0
  @@update_count = 0

  def self.destroy_count
    @@destroy_count
  end

  def self.update_count
    @@update_count
  end

  def after_destroy(android)
    @@destroy_count += 1
  end

  def after_update(android)
    @@update_count += 1
  end
end

ActiveRecord::Base.observers = AndroidObserver
ActiveRecord::Base.instantiate_observers

describe Android do
  before(:each) do
    Android.connection.execute 'DELETE FROM androids'
    Person.connection.execute 'DELETE FROM people'

    @luke = Person.create!(:name => 'Luke Skywalker')
    @r2d2 = Android.create!(:name => 'R2D2', :owner_id => @luke.id)
    @c3p0 = Android.create!(:name => 'C3P0', :owner_id => @luke.id)
  end

  it "should delete normally" do
    Android.count_with_destroyed.should == 2
    Android.delete_all
    Android.count_with_destroyed.should == 0
  end

  it "should handle Model.destroy_all properly" do
    lambda{
      Android.destroy_all("owner_id = #{@luke.id}")
    }.should change(Android, :count).from(2).to(0)
    Android.count_with_destroyed.should == 2
  end

  it "should handle Model.destroy(id) properly" do
    lambda{
      Android.destroy(@r2d2.id)
    }.should change(Android, :count).by(-1)

    Android.count_with_destroyed.should == 2
  end

  it "should be not show up in the relationship to the owner once deleted" do
    @luke.androids.size.should == 2
    @r2d2.destroy
    @luke.androids.size.should == 1
    Android.count.should == 1
    Android.first(:conditions => {:name => 'R2D2'}).should be_blank
  end

  it "should be able to find deleted items via find_with_destroyed" do
    @r2d2.destroy
    Android.find(:first, :conditions => {:name => 'R2D2'}).should be_blank
    Android.find_with_destroyed(:first, :conditions => {:name => 'R2D2'}).should_not be_blank
  end

  it "should be able to find deleted items via destroyed scope" do
    @r2d2.destroy
    Android.where(:name => 'R2D2').first.should be_blank
    Android.destroyed do
      where(:name => 'R2D2').first.should_not be_blank
    end
  end

  it "should have a proper count inclusively and exclusively of deleted items" do
    @r2d2.destroy
    @c3p0.destroy
    Android.count.should == 0
    Android.count_with_destroyed.should == 2
  end

  it "should mark deleted on dependent destroys" do
    lambda{
      @luke.destroy
    }.should change(Android, :count).by(-2)
    Android.count_with_destroyed.should == 2
  end

  it "should allow restoring" do
    @r2d2.destroy

    lambda{
      @r2d2.restore
    }.should change(Android, :count).by(1)
  end

  # Note:  this isn't necessarily ideal, this just serves to demostrate
  # how it currently works
  it "should not ignore deleted items in validation checks" do
    @r2d2.destroy
    lambda{
      Android.create!(:name => 'R2D2')
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it "should find only destroyed videos" do
    @r2d2.destroy
    Android.destroyed.all.should == [@r2d2]
  end

  describe "scopes" do
    before do
      @r2d2.destroy
      @c3p0.destroy
    end

    it "should only find r2d2 through it's scope" do
      Android.destroyed do
        r2d2.should == [@r2d2]
      end
    end

    it "should only find c3p0 through it's scope" do
      Android.destroyed do
        c3p0.ordered.should == [@c3p0]
      end
    end

    it "should fint both r2d2 and c3p0 in correct order" do
      Android.destroyed do
        ordered.should == [@r2d2, @c3p0]
      end
    end

    it "should not find any destroyed if scopes added makes SQL hit non of them" do
      Android.destroyed do
        r2d2.c3p0.should == []
      end
    end

    it "should include both r2d2 and c3p0" do
      Android.destroyed.should == [@r2d2, @c3p0]
    end
  end

  it "should restore the original scope when an exception occurs" do
    @r2d2.destroy
    count = Android.count

    # Ensure the bug this test addresses hasn't leaked from other
    # tests. This has actually happened!
    count.should == 1

    # This triggers the bug but I'm not entirely sure why.
    Android.ordered.find_with_destroyed(:all) rescue nil

    Android.count.should == count
  end

  describe "invalid object" do
    before do
      @r2d2.stub!(:valid?).and_return false
    end

    it "should be able to be destroyed" do
      lambda { @r2d2.destroy }.should change(Android, :count).by(-1)
    end

    it "should be able to be restored" do
      @r2d2.destroy
      lambda { @r2d2.restore }.should change(Android, :count).by(1)
    end
  end

  describe "callbacks" do
    it "should call after_destroy" do
      lambda { @r2d2.destroy }.should change(AndroidObserver, :destroy_count).by(1)
    end

    it "should not call after_update" do
      lambda { @r2d2.destroy }.should_not change(AndroidObserver, :update_count)
    end
  end
end

