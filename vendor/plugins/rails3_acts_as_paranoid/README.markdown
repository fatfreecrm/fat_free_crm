# ActsAsParanoid

A simple plugin which hides records instead of deleting them, being able to recover them.

## Credits

This plugin was inspired by [acts_as_paranoid](http://github.com/technoweenie/acts_as_paranoid) and [acts_as_active](http://github.com/fernandoluizao/acts_as_active).

While porting it to Rails 3, I decided to apply the ideas behind those plugins to an unified solution while removing a **lot** of the complexity found in them. I eventually ended up writing a new plugin from scratch.

## Usage

You can enable ActsAsParanoid like this:

    class Paranoiac < ActiveRecord::Base
      acts_as_paranoid
    end

### Options

You can also specify the name of the column to store it's *deletion* and the type of data it holds:

-   :column => 'deleted_at'
-   :type => 'time'

The values shown are the defaults. While *column* can be anything (as long as it exists in your database), *type* is restricted to "boolean" or "time".

### Filtering

If a record is deleted by ActsAsParanoid, it won't be retrieved when accessing the database. So, `Paranoiac.all` will **not** include the deleted_records. if you want to access them, you have 2 choices:
    Paranoiac.only_deleted # retrieves the deleted records
    Paranoiac.with_deleted # retrieves all records, deleted or not

### Real deletion

In order to really delete a record, just use:
    paranoiac.destroy!
    Paranoiac.delete_all!(conditions)

You can also definitively delete a record by calling `destroy` or `delete_all` on it twice. If a record was already deleted (hidden by ActsAsParanoid) and you delete it again, it will be removed from the database. Take this example:
    Paranoiac.first.destroy # does NOT delete the first record, just hides it
    Paranoiac.only_deleted.destroy # deletes the first record from the database

### Recovery

Recovery is easy. Just invoke `recover` on it, like this:
    Paranoiac.only_deleted.where("name = ?", "not dead yet").first.recover

## Caveats

Watch out for these caveats:

-   If you use default\_scope in your model, you need to include it after the `acts_as_paranoid` invocation
-   You cannot use scopes named `with_deleted` and `only_deleted`

Copyright © 2010 Gonçalo Silva, released under the MIT license
