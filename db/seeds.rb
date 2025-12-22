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
  { name: "Langata", county: "Nairobi", ward: "Langata" }
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

puts "Seeding complete!"