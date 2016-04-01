# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# ~ require Rails.root.join('db/seeds/fields')

Contract.destroy_all

bronze = Contract.create!(name: 'Bronze')
silver = Contract.create!(name: 'Silver')
gold = Contract.create!(name: 'Gold')
platinum = Contract.create!(name: 'Platinum')
