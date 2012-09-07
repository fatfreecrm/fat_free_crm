require "fat_free_crm/core_ext/string"

describe "String" do
  it "should generate all possible combinations of first and last name from a query" do
    expected = [
      ["Stephanie", "Man Chi Lo"],
      ["Stephanie Man", "Chi Lo"],
      ["Stephanie Man Chi", "Lo"],
      ["Lo", "Stephanie Man Chi"],
      ["Chi Lo", "Stephanie Man"],
      ["Man Chi Lo", "Stephanie"]
    ]
    result = "Stephanie Man Chi Lo".name_permutations
    result.sort.should == expected.sort
  end
end
