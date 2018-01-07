# frozen_string_literal: true

class ConvertRadioToRadioButtons < ActiveRecord::Migration[4.2]
  def up
    # UPDATE "fields" SET "as" = 'radio_buttons' WHERE "fields"."as" = $1  [["as", "radio"]]
    Field.where(as: 'radio').update_all(as: 'radio_buttons')
  end

  def down
    Field.where(as: 'radio_buttons').update_all(as: 'radio')
  end
end
