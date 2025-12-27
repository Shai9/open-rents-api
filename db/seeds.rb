puts "Seeding Nairobi neighborhoods..."

neighborhoods = [
  { name: "Donholm", county: "Nairobi", ward: "Upper Savannah" },
  { name: "Fedha", county: "Nairobi", ward: "Embakasi" },
  { name: "Umoja", county: "Nairobi", ward: "Embakasi West" },
  { name: "Lavington", county: "Nairobi", ward: "Lavington" },
  { name: "Parklands", county: "Nairobi", ward: "Parklands" },
  { name: "Karen", county: "Nairobi", ward: "Karen" },
  { name: "Runda", county: "Nairobi", ward: "Runda" },
  { name: "South B", county: "Nairobi", ward: "South B" },
  { name: "South C", county: "Nairobi", ward: "South C" },
  { name: "Langata", county: "Nairobi", ward: "Langata" },
  { name: "Kileleshwa", county: "Nairobi", ward: "Kileleshwa" },
  { name: "Kilimani", county: "Nairobi", ward: "Kilimani" },
]

neighborhoods.each do |neighborhood_data|
  Neighborhood.find_or_create_by!(neighborhood_data)
  puts "Created/Found: #{neighborhood_data[:name]}"
end

puts "Seeding test users..."

test_users = [
  { phone_number: "+254711222333" },
  { phone_number: "+254722333444" },
  { phone_number: "+254733444555" }
]

test_users.each do |user_data|
  user = User.find_or_create_by!(phone_number: user_data[:phone_number])
  
  if user.sms_verification_code.present?
    user.verify!(user.sms_verification_code)
    user.update!(trust_score: 0.8, consistency_score: 0.85)
  end
  
  puts "Created/Found user: #{user.phone_number} (Trust: #{user.trust_score})"
end

puts "Seeding sample reports..."

user = User.first
kileleshwa = Neighborhood.find_by(name: "Kileleshwa")
kilimani = Neighborhood.find_by(name: "Kilimani")

sample_reports = [
  {
    user: user,
    neighborhood: kileleshwa,
    report_type: "water_reliability",
    value: "Good",
    details: "Water available 5-6 days a week. Reliable schedule.",
    confidence: 0.85
  },
  {
    user: user,
    neighborhood: kileleshwa,
    report_type: "security",
    value: "Safe",
    details: "24/7 guards in most apartments. CCTV common.",
    confidence: 0.82
  },
  {
    user: user,
    neighborhood: kileleshwa,
    report_type: "noise_levels",
    value: "Moderate",
    details: "Quiet after 10 PM. Some generator noise during outages.",
    confidence: 0.78
  },
  {
    user: user,
    neighborhood: kilimani,
    report_type: "water_reliability",
    value: "Fair",
    details: "Water rationing during dry season.",
    confidence: 0.75
  },
  {
    user: user,
    neighborhood: kilimani,
    report_type: "internet_speed",
    value: "Excellent",
    details: "Fiber available from multiple providers.",
    confidence: 0.92
  }
]

sample_reports.each do |report_data|
  report = Report.create!(report_data)
  report.verify! 
  
  puts "Created report: #{report.report_type} for #{report.neighborhood.name}"
  
  if report.report_type == "water_reliability"
    other_user = User.second
    if other_user
      Verification.create!(
        user: other_user,
        report: report,
        agrees: true,
        comment: "I confirm this is accurate"
      )
      puts "  Added verification from #{other_user.phone_number}"
    end
  end
end

puts "Sample reports seeded!"

puts "Seeding complete!"