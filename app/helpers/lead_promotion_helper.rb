# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
module LeadPromotionHelper
    # Promote the lead by creating a contact and optional opportunity. Upon
    # successful promotion Lead status gets set to :converted.
    #----------------------------------------------------------------------------  
    def promote_lead(lead, params)
      account_params = params[:account] || {}
      opportunity_params = params[:opportunity] || {}
  
      account     = Account.create_or_select_for(lead, account_params)
      opportunity = Opportunity.create_for(lead, account, opportunity_params)
      contact     = Contact.create_for(lead, account, opportunity, params)
  
      [account, opportunity, contact]
    end
  end
  