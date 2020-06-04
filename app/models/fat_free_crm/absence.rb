# frozen_string_literal: true

#  id              :integer         not null, primary key
#  contact_id      :integer
#  kind            :string(64)      default(""), not null
#  start_on        :date
#  end_on          :date
#  deleted_at      :date

module FatFreeCrm
  class Absence < ActiveRecord::Base

  end
end

