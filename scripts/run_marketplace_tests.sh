#!/bin/bash

# Marketplace Testing Runner Script
# Script ini memudahkan menjalankan semua test marketplace

echo "🚀 MARKETPLACE TESTING RUNNER"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to run tests
run_test() {
    local test_name=$1
    local test_path=$2
    
    echo -e "${BLUE}📝 Running: $test_name${NC}"
    echo "Path: $test_path"
    echo ""
    
    flutter test "$test_path"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $test_name - PASSED${NC}"
    else
        echo -e "${RED}❌ $test_name - FAILED${NC}"
    fi
    echo "================================"
    echo ""
}

# Menu
echo "Select test to run:"
echo "1. E2E Admin Marketplace"
echo "2. E2E Warga Belanja"
echo "3. E2E Warga Toko Saya"
echo "4. Integration Test"
echo "5. All E2E Tests"
echo "6. All Integration Tests"
echo "7. ALL MARKETPLACE TESTS"
echo "8. Exit"
echo ""
read -p "Enter choice [1-8]: " choice

case $choice in
    1)
        run_test "E2E Admin Marketplace" "integration_test/end_to_end/marketplace/admin/marketplace_admin_e2e_test.dart"
        ;;
    2)
        run_test "E2E Warga Belanja" "integration_test/end_to_end/marketplace/warga/belanja_e2e_test.dart"
        ;;
    3)
        run_test "E2E Warga Toko Saya" "integration_test/end_to_end/marketplace/warga/toko_saya_e2e_test.dart"
        ;;
    4)
        run_test "Integration Test" "integration_test/integration/marketplace/marketplace_integration_test.dart"
        ;;
    5)
        echo -e "${YELLOW}🔄 Running all E2E tests...${NC}"
        echo ""
        run_test "E2E Admin" "integration_test/end_to_end/marketplace/admin/marketplace_admin_e2e_test.dart"
        run_test "E2E Belanja" "integration_test/end_to_end/marketplace/warga/belanja_e2e_test.dart"
        run_test "E2E Toko Saya" "integration_test/end_to_end/marketplace/warga/toko_saya_e2e_test.dart"
        echo -e "${GREEN}✅ All E2E tests completed!${NC}"
        ;;
    6)
        echo -e "${YELLOW}🔄 Running all Integration tests...${NC}"
        echo ""
        run_test "Integration Test" "integration_test/integration/marketplace/marketplace_integration_test.dart"
        echo -e "${GREEN}✅ All Integration tests completed!${NC}"
        ;;
    7)
        echo -e "${YELLOW}🔄 Running ALL marketplace tests...${NC}"
        echo ""
        run_test "E2E Admin" "integration_test/end_to_end/marketplace/admin/marketplace_admin_e2e_test.dart"
        run_test "E2E Belanja" "integration_test/end_to_end/marketplace/warga/belanja_e2e_test.dart"
        run_test "E2E Toko Saya" "integration_test/end_to_end/marketplace/warga/toko_saya_e2e_test.dart"
        run_test "Integration Test" "integration_test/integration/marketplace/marketplace_integration_test.dart"
        echo ""
        echo -e "${GREEN}🎉 ALL MARKETPLACE TESTS COMPLETED!${NC}"
        ;;
    8)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice!${NC}"
        exit 1
        ;;
esac

echo ""
echo "================================"
echo -e "${BLUE}📊 Test Summary${NC}"
echo "Check test results above"
echo "For detailed report, see test output"
echo "================================"
