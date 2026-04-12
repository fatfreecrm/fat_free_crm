require 'spec_helper'

describe "WhatsApp Support" do
  it "should validate whatsapp length on Lead" do
    lead = Lead.new(whatsapp: "a" * 129)
    expect(lead).not_to be_valid
    expect(lead.errors[:whatsapp]).to include("is too long (maximum is 128 characters)")
  end

  it "should validate whatsapp length on Contact" do
    contact = Contact.new(whatsapp: "a" * 129)
    expect(contact).not_to be_valid
    expect(contact.errors[:whatsapp]).to include("is too long (maximum is 128 characters)")
  end

  it "should validate whatsapp length on User" do
    user = User.new(whatsapp: "a" * 129)
    expect(user).not_to be_valid
    expect(user.errors[:whatsapp]).to include("is too long (maximum is 128 characters)")
  end

  it "should carry over whatsapp when promoting a lead" do
    lead = FactoryBot.create(:lead, whatsapp: "123456789")
    account = FactoryBot.create(:account)
    opportunity = FactoryBot.create(:opportunity)

    contact = Contact.create_for(lead, account, opportunity, {account: {}, opportunity: {}, access: "Public"})
    expect(contact.whatsapp).to eq("123456789")
  end
end
