module KiosksHelper

  def accounts_list
    Account.all.map { |acc| [acc.name, acc.id] }.sort!
  end

  def contract_list
    Contract.all.map { |con| [con.name, con.id] }
  end

end
