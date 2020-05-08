module FatFreeCrm
  class Document < ApplicationRecord
    has_one_attached :file

    def uploaded_username
      user = User.find(uploaded_by_id)
      user.first_name.to_s + ' ' + user.last_name.to_s
    end

    def uploaded_by
      User.find(uploaded_by_id)
    end
  end
end
