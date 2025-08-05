puts "Seeding Research Tools..."

ResearchTool.find_or_create_by!(name: "Google") do |tool|
  tool.url_template = "https://www.google.com/search?q={name}"
  tool.enabled = true
end

ResearchTool.find_or_create_by!(name: "LinkedIn") do |tool|
  tool.url_template = "https://www.linkedin.com/search/results/all/?keywords={name}"
  tool.enabled = true
end

ResearchTool.find_or_create_by!(name: "OpenCorporates") do |tool|
  tool.url_template = "https://opencorporates.com/companies?q={name}"
  tool.enabled = true
end

ResearchTool.find_or_create_by!(name: "Australian Business Register") do |tool|
  tool.url_template = "https://abr.business.gov.au/Search?SearchText={name}"
  tool.enabled = true
end

puts "Seeding Research Tools complete."
