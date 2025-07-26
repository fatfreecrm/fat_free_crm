# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path('acceptance_helper.rb', __dir__)

feature 'Products', '
  In order to be able to make sales
  As a user
  I want to manage products
' do
  before :each do
    do_login_if_not_already(first_name: 'Bill', last_name: 'Murray')
  end

  scenario 'should view a list of products' do
    3.times { |i| create(:product, name: "Product #{i}") }
    visit products_page
    expect(page).to have_content('Product 0')
    expect(page).to have_content('Product 1')
    expect(page).to have_content('Product 2')
    expect(page).to have_content('Create Product')
  end

  scenario 'should create a new product', js: true do
    with_versioning do
      visit products_page
      click_link 'Create Product'
      expect(page).to have_selector('#product_name', visible: true)
      fill_in 'product_name', with: 'My Awesome Product'
      click_link 'Comment'
      fill_in 'comment_body', with: 'This is a very important product.'
      click_button 'Create Product'
      expect(page).to have_content('My Awesome Product')

      find('div#products').click_link('My Awesome Product')
      expect(page).to have_content('This is a very important product.')

      click_link "Dashboard"
      expect(page).to have_content("Bill Murray created product My Awesome Product")
      expect(page).to have_content("Bill Murray created comment on My Awesome Product")
    end
  end

  scenario 'should view and edit an product', js: true do
    create(:product, name: 'A Cool Product')
    with_versioning do
      visit products_page
      click_link 'A Cool Product'
      click_link 'Edit'
      fill_in 'product_name', with: 'An Even Cooler Product'
      select2 'Other Example Account', from: 'Account (create new or select existing):'
      select2 'Analysis', from: 'Stage:'
      click_button 'Save Product'
      expect(page).to have_content('An Even Cooler Product')
      click_link "Dashboard"
      expect(page).to have_content("Bill Murray updated product An Even Cooler Product")
    end
  end

  scenario 'should delete an product', js: true do
    create(:product, name: 'Outdated Product')
    visit products_page
    click_link 'Outdated Product'
    click_link 'Delete?'
    expect(page).to have_content('Are you sure you want to delete this product?')
    click_link 'Yes'
    expect(page).to have_content('Outdated Product has been deleted.')
  end

  scenario 'should search for an product', js: true do
    2.times { |i| create(:product, name: "Product #{i}") }
    visit products_page
    expect(find('#products')).to have_content("Product 0")
    expect(find('#products')).to have_content("Product 1")
    fill_in 'query', with: "Product 0"
    expect(find('#products')).to have_content("Product 0")
    expect(find('#products')).not_to have_content("Product 1")
    fill_in 'query', with: "Product"
    expect(find('#products')).to have_content("Product 0")
    expect(find('#products')).to have_content("Product 1")
    fill_in 'query', with: "Non-existant product"
    expect(find('#products')).not_to have_content("Product 0")
    expect(find('#products')).not_to have_content("Product 1")
  end

  scenario 'should add comment to product', js: true do
    product = create(:product, name: 'Awesome Product')
    visit products_page
    click_link 'Awesome Product'
    find("#product_#{product.id}_post_new_note").click
    fill_in 'comment[comment]', with: 'Most awesome product'
    click_button 'Add Comment'
    expect(page).to have_content('Most awesome product')
  end
end
