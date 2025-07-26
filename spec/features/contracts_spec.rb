# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Contracts', '
  In order to increase sales
  As a user
  I want to manage contracts
' do
  before :each do
    do_login_if_not_already(first_name: 'Bill', last_name: 'Murray')
  end

  scenario 'should view a list of contracts' do
    3.times { |i| create(:contract, name: "Contract #{i}") }
    visit contracts_page
    expect(page).to have_content('Contract 0')
    expect(page).to have_content('Contract 1')
    expect(page).to have_content('Contract 2')
    expect(page).to have_content('Create Contract')
  end

  scenario 'should create a new contract', js: true do
    create(:account, name: 'Example Account')
    with_versioning do
      visit contracts_page
      click_link 'Create Contract'
      expect(page).to have_selector('#contract_name', visible: true)
      fill_in 'contract_name', with: 'My Awesome Contract'
      click_link 'select existing'
      find('#select2-account_id-container').click
      find('.select2-search--dropdown').find('input').set('Example Account')
      sleep(1)
      find('li', text: 'Example Account').click
      expect(page).to have_content('Example Account')
      select2 'Prospecting', from: 'Stage'
      click_link 'Comment'
      fill_in 'comment_body', with: 'This is a very important contract.'
      click_button 'Create Contract'
      expect(page).to have_content('My Awesome Contract')

      find('div#contracts').click_link('My Awesome Contract')
      expect(page).to have_content('This is a very important contract.')

      click_link "Dashboard"
      expect(page).to have_content("Bill Murray created contract My Awesome Contract")
      expect(page).to have_content("Bill Murray created comment on My Awesome Contract")
    end
  end

  scenario 'should not display ammount with zero value', js: true do
    with_amount = create(:contract, name: 'With Amount', amount: 3000, probability: 90, discount: nil, stage: 'proposal')
    without_amount = create(:contract, name: 'Without Amount', amount: nil, probability: nil, discount: nil, stage: 'proposal')
    with_versioning do
      visit contracts_page
      click_link 'Long format'
      expect(find("#contract_#{with_amount.id}")).to have_content('$3,000 | Probability 90%')
      expect(find("#contract_#{without_amount.id}")).not_to have_content('$0 | Discount $0 | Probability 0%')
    end
  end

  scenario "remembers the comment field when the creation was unsuccessful", js: true do
    visit contracts_page
    click_link 'Create Contract'
    select2 'Prospecting', from: 'Stage:'

    click_link 'Comment'
    fill_in 'comment_body', with: 'This is a very important contract.'
    click_button 'Create Contract'

    expect(page).to have_field('comment_body', with: 'This is a very important contract.')
  end

  scenario 'should view and edit an contract', js: true do
    create(:account, name: 'Example Account')
    create(:account, name: 'Other Example Account')
    create(:contract, name: 'A Cool Contract')
    with_versioning do
      visit contracts_page
      click_link 'A Cool Contract'
      click_link 'Edit'
      fill_in 'contract_name', with: 'An Even Cooler Contract'
      select2 'Other Example Account', from: 'Account (create new or select existing):'
      select2 'Analysis', from: 'Stage:'
      click_button 'Save Contract'
      expect(page).to have_content('An Even Cooler Contract')
      click_link "Dashboard"
      expect(page).to have_content("Bill Murray updated contract An Even Cooler Contract")
    end
  end

  scenario 'should delete an contract', js: true do
    create(:contract, name: 'Outdated Contract')
    visit contracts_page
    click_link 'Outdated Contract'
    click_link 'Delete?'
    expect(page).to have_content('Are you sure you want to delete this contract?')
    click_link 'Yes'
    expect(page).to have_content('Outdated Contract has been deleted.')
  end

  scenario 'should search for an contract', js: true do
    2.times { |i| create(:contract, name: "Contract #{i}") }
    visit contracts_page
    expect(find('#contracts')).to have_content("Contract 0")
    expect(find('#contracts')).to have_content("Contract 1")
    fill_in 'query', with: "Contract 0"
    expect(find('#contracts')).to have_content("Contract 0")
    expect(find('#contracts')).not_to have_content("Contract 1")
    fill_in 'query', with: "Contract"
    expect(find('#contracts')).to have_content("Contract 0")
    expect(find('#contracts')).to have_content("Contract 1")
    fill_in 'query', with: "Non-existant contract"
    expect(find('#contracts')).not_to have_content("Contract 0")
    expect(find('#contracts')).not_to have_content("Contract 1")
  end

  scenario 'should add comment to contract', js: true do
    contract = create(:contract, name: 'Awesome Contract')
    visit contracts_page
    click_link 'Awesome Contract'
    find("#contract_#{contract.id}_post_new_note").click
    fill_in 'comment[comment]', with: 'Most awesome contract'
    click_button 'Add Comment'
    expect(page).to have_content('Most awesome contract')
  end
end
