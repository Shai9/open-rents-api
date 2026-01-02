#!/bin/bash

echo "🚀 OPENRENTS API - FULL TEST SUITE"
echo "=================================="
echo

echo "1️⃣  Starting Rails server..."
# Check if server is already running
if ! curl -s http://localhost:3000/api/v1/health > /dev/null; then
    echo "   Starting server in background..."
    rails server -d
    sleep 5
else
    echo "   Server already running"
fi

echo
echo "2️⃣  Running basic health checks..."
./test_complete_api.sh

echo
echo "3️⃣  Running edge case tests..."
./test_edge_cases.sh

echo
echo "4️⃣  Verifying database state..."
ruby verify_database.rb

echo
echo "5️⃣  Performance check..."
echo "   Health endpoint:"
curl -s -o /dev/null -w "   Response time: %{time_total}s\n" http://localhost:3000/api/v1/health

echo
echo "6️⃣  Final validation..."
echo "   Testing all endpoints one more time:"

ENDPOINTS=(
    "/health"
    "/database/status"
    "/neighborhoods"
    "/neighborhoods/kileleshwa"
    "/neighborhoods/kileleshwa/reports"
    "/reports"
)

for endpoint in "${ENDPOINTS[@]}"; do
    status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/v1${endpoint}")
    if [ "$status" = "200" ] || [ "$status" = "201" ]; then
        echo "   ✅ $endpoint (HTTP $status)"
    else
        echo "   ❌ $endpoint (HTTP $status)"
    fi
done

echo
echo "=================================="
echo "🎉 TESTING COMPLETE!"
echo
echo "Next steps:"
echo "1. Review test results above"
echo "2. Check Postman collection for detailed API testing"
echo "3. Run 'rails console' to verify database state"
echo "4. Consider adding RSpec tests for long-term maintenance"
