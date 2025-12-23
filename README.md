# OpenRents - Nairobi Rental Intelligence Platform

OpenRents is a community-driven rental intelligence platform built specifically for Nairobi's rental market. It aggregates fragmented, untrusted rental data into confidence-aware neighborhood insights through a transparent trust scoring system.

## Problem Statement

Nairobi's rental market operates on fragmented, unverified information:
- **Fragmented Data**: Information scattered across WhatsApp, Facebook, broker notes
- **No Trust Signals**: Can't distinguish between genuine reports and biased information
- **Outdated Information**: Water schedules from dry season don't apply during rainy season
- **No Quality Filters**: All information treated equally regardless of source credibility

## Solution

OpenRents treats rental data as **signals with varying confidence levels**. Trust emerges from community consensus, not authority. Every piece of information carries its own confidence score based on verification patterns.

### Core Principles:
- **Community Verification**: Residents verify each other's reports
- **Transparent Trust Scoring**: Users see exactly how confidence is calculated
- **Nairobi-First Design**: Built for Kenya's SMS-first mobile culture
- **Real Problems Solved**: Water reliability, estate-level security, generator noise

## Architecture

### Tech Stack
- **Backend**: Ruby on Rails 8.0.4 (API-only)
- **Database**: PostgreSQL with PostGIS (for spatial queries)
- **Authentication**: SMS-based verification (Twilio integration)
- **Job Processing**: Sidekiq with Redis
- **API**: RESTful JSON API

### Core Models
1. **User** - SMS-verified residents with trust scores
2. **Neighborhood** - Nairobi neighborhoods with geospatial data
3. **Report** - User-submitted rental insights (water, security, noise, etc.)
4. **Verification** - Community validation of reports
5. **Insight** - Aggregated neighborhood intelligence (coming soon)

## Getting Started

### Prerequisites
- Ruby 3.4.5
- PostgreSQL 12+
- Bundler

### Installation

1. **Clone the repository**
```bash
git clone <https://github.com/shai9/open-rents-api>
cd open-rents-api
```

2. **Install dependencies**
```bash
bundle install
```

3. **Setup database**
```bash
rails db:create

rails db:migrate

rails db:seed
```

4. **Configure environment variables**
```bash
cp .env.yourenv .env
```

5. **Start the server**
```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Health Check
```bash
GET /health
```

Response:
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2024-01-15T12:00:00Z",
    "environment": "development",
    "database": "connected",
    "neighborhoods_count": 10,
    "users_count": 3
  }
}
```

### Authentication Flow

1. **Request SMS Verification**
```bash
POST /users/request_verification
{
  "phone_number": "0712657575"
}
```

2. **Verify Code** (Development mode returns code)
```bash
POST /users/verify
{
  "user_id": 1,
  "verification_code": "123456"
}
```

3. **Login**
```bash
POST /users/login
{
  "phone_number": "+254711222333"
}
```

4. **Use token in Authorization header**
```
Authorization: Bearer <user_id>
```

### Neighborhoods

**List all neighborhoods**
```bash
GET /neighborhoods
```

**Get specific neighborhood**
```bash
GET /neighborhoods/kileleshwa
```

**Get neighborhood reports**
```bash
GET /neighborhoods/kileleshwa/reports
```

**Get neighborhood insights** (aggregated data)
```bash
GET /neighborhoods/kileleshwa/insights
```

### Reports

**List reports** (with filters)
```bash
GET /reports
GET /reports?neighborhood_id=1
GET /reports?report_type=water_reliability
GET /reports?verified=true
```

**Create report** (requires authentication)
```bash
POST /reports
Authorization: Bearer <user_id>
{
  "report": {
    "neighborhood_id": 1,
    "report_type": "water_reliability",
    "value": "Good",
    "details": "Water available 5-6 days a week"
  }
}
```

**Report types available:**
- `water_reliability`
- `security`
- `noise_levels`
- `internet_speed`
- `garbage_collection`
- `parking_availability`
- `transport_access`
- `air_quality`
- `flooding_risk`
- `power_reliability`

## 🔧 Trust Scoring System

### Report Confidence Formula
```
confidence = (user_trust × 0.3) + (consensus × 0.7)
```

### User Trust Score
```
trust_score = base_score + report_bonus + consistency_bonus
```

Where:
- **Base score**: 0.6 for verified users, 0.3 for unverified
- **Report bonus**: `log10(reports_count + 1) × 0.1`
- **Consistency bonus**: `consistency_score × 0.3`

### Auto-Verification
Reports are automatically verified when:
- At least 3 verifications received
- 70% or higher agreement rate

## Nairobi Neighborhoods Included

- Kileleshwa
- Kilimani
- Westlands
- Lavington
- Parklands
- Karen
- Runda
- Umoja
- Fedha
- Donholm
- South B
- South C
- Langata

## Current Status

### Implemented
- [x] User model with SMS verification
- [x] Neighborhood model with Nairobi data
- [x] Report system with community verification
- [x] Trust scoring algorithms
- [x] RESTful API endpoints
- [x] Authentication system
- [x] Database health checks
- [x] Sample data seeding

### In Progress
- [ ] Insight model (aggregated neighborhood intelligence)
- [ ] Twilio SMS integration
- [ ] Real-time updates
- [ ] Admin dashboard
- [ ] API documentation

### 📋 Planned
- [ ] Mobile app (React Native)
- [ ] Web dashboard (Next.js)
- [ ] Advanced analytics
- [ ] Neighborhood alerts
- [ ] Broker verification system

## 🧪 Testing the API

### Quick Test Script
```bash
curl http://localhost:3000/api/v1/health

curl http://localhost:3000/api/v1/neighborhoods

curl http://localhost:3000/api/v1/neighborhoods/kileleshwa/reports

curl http://localhost:3000/api/v1/database/status
```

### Sample Report Creation
```bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/v1/users/login \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+254711222333"}' | jq -r '.data.token')

curl -X POST http://localhost:3000/api/v1/reports \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "report": {
      "neighborhood_id": 1,
      "report_type": "security",
      "value": "Safe",
      "details": "Good security, regular patrols"
    }
  }'
```

## Project Structure

```
openrents-api/
├── app/
│   ├── controllers/
│   │   └── api/v1/
│   │       ├── base_controller.rb
│   │       ├── health_controller.rb
│   │       ├── neighborhoods_controller.rb
│   │       ├── reports_controller.rb
│   │       ├── users_controller.rb
│   │       └── database_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── neighborhood.rb
│   │   ├── report.rb
│   │   └── verification.rb
│   └── views/
├── config/
│   ├── routes.rb
│   ├── database.yml
│   └── initializers/
├── db/
│   ├── migrate/
│   ├── schema.rb
│   └── seeds.rb
└── spec/
```
## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the need for trustworthy rental information in Nairobi
- Built with feedback from Nairobi residents
- Thanks to the Rails community for excellent tooling

## Contact

Calmus Dennis - [@calmus](https://twitter.com/calmus) - calmusdennis254@gmail.com

Project Link: [https://github.com/shai9/open-rents-api](https://github.com/shai9/openrents)

---

**Next Steps**: We're currently building the Insight model to aggregate individual reports into comprehensive neighborhood intelligence. Stay tuned!