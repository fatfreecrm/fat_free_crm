# frozen_string_literal: true
# This migration comes from fat_free_crm (originally 20150123060900)

class ConvertRadioToRadioButtons < ActiveRecord::Migration[4.2]
  def up
    # UPDATE "fields" SET "as" = 'radio_buttons' WHERE "fields"."as" = $1  [["as", "radio"]]
    FatFreeCrm::Field.where(as: 'radio').update_all(as: 'radio_buttons')
  end

  def down
    FatFreeCrm::Field.where(as: 'radio_buttons').update_all(as: 'radio')
  end
end
