Warning
=======

As stated in the git repository as the original author of this code:
"This library is no longer supported or actively developed by the original author.
It never made it to a 1.0 stable version. Use it at your own risk and write lots of tests."

..So why I am trying to make it Rails 3 compatible? Well, I have an application which uses
this code, and as I'd like to upgrade it to Rails 3 I guess I should keep this code base up
to date too. But, you might want to think twice if you want to use this in your new and 
shining Rails 3 application..


Are you paranoid?
=================

Destroying records is a one-way ticket--you are permanently sending data
down the drain. *Unless*, of course, you are using this plugin.

Simply declare models paranoid:

    class User < ActiveRecord::Base
      is_paranoid
    end

You will need to add the "deleted_at" datetime column on each model table
you declare paranoid. This is how the plugin tracks destroyed state.


Destroying
----------

Calling `destroy` should work as you expect, only it doesn't actually delete the record:

    User.count  #=> 1
    
    User.first.destroy
    
    User.count  #=> 0
    
    # user is still there, only hidden:
    User.count_with_destroyed  #=> 1

What `destroy` does is that it sets the "deleted\_at" column to the current time.
Records that have a value for "deleted\_at" are considered deleted and are filtered
out from all requests using `default_scope` ActiveRecord feature:

    default_scope :conditions => {:deleted_at => nil}

Restoring
---------

No sense in keeping the data if we can't restore it, right?

    user = User.find_with_destroyed(:first)
    
    user.restore
    
    User.count  #=> 1

Restoring resets the "deleted_at" value back to `nil`.

Extra methods
-------------

Extra class methods provided by this plugin are:

1. `Model.count_with_destroyed(*args)`
2. `Model.find_with_destroyed(*args)`
2. `Model.destroyed` # Returns all destroyed, accepts a block with where() etc. See spec for examples.


Pitfalls
--------

* `validates_uniqueness_of` does not ignore items marked with a "deleted_at" flag
* various eager-loading and associations-related issues (see ["Killing is_paranoid"](http://blog.semanticart.com/killing_is_paranoid/))
