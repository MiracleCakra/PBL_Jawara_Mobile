@echo off
REM Marketplace Testing Runner Script (Windows)
REM Script ini memudahkan menjalankan semua test marketplace

title Marketplace Testing Runner

echo ========================================
echo   MARKETPLACE TESTING RUNNER
echo ========================================
echo.

:menu
echo Select test to run:
echo.
echo 1. E2E Admin Marketplace
echo 2. E2E Warga Belanja
echo 3. E2E Warga Toko Saya
echo 4. Integration Test
echo 5. All E2E Tests
echo 6. All Integration Tests
echo 7. ALL MARKETPLACE TESTS
echo 8. Exit
echo.

set /p choice="Enter choice [1-8]: "

if "%choice%"=="1" goto admin
if "%choice%"=="2" goto belanja
if "%choice%"=="3" goto toko
if "%choice%"=="4" goto integration
if "%choice%"=="5" goto all_e2e
if "%choice%"=="6" goto all_integration
if "%choice%"=="7" goto all_tests
if "%choice%"=="8" goto exit
goto invalid

:admin
echo.
echo ========================================
echo Running: E2E Admin Marketplace
echo ========================================
echo.
flutter test integration_test\end_to_end\marketplace\admin\marketplace_admin_e2e_test.dart
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] E2E Admin Marketplace - PASSED
) else (
    echo.
    echo [FAILED] E2E Admin Marketplace - FAILED
)
goto end

:belanja
echo.
echo ========================================
echo Running: E2E Warga Belanja
echo ========================================
echo.
flutter test integration_test\end_to_end\marketplace\warga\belanja_e2e_test.dart
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] E2E Warga Belanja - PASSED
) else (
    echo.
    echo [FAILED] E2E Warga Belanja - FAILED
)
goto end

:toko
echo.
echo ========================================
echo Running: E2E Warga Toko Saya
echo ========================================
echo.
flutter test integration_test\end_to_end\marketplace\warga\toko_saya_e2e_test.dart
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] E2E Warga Toko Saya - PASSED
) else (
    echo.
    echo [FAILED] E2E Warga Toko Saya - FAILED
)
goto end

:integration
echo.
echo ========================================
echo Running: Integration Test
echo ========================================
echo.
flutter test integration_test\integration\marketplace\marketplace_integration_test.dart
if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] Integration Test - PASSED
) else (
    echo.
    echo [FAILED] Integration Test - FAILED
)
goto end

:all_e2e
echo.
echo ========================================
echo Running: ALL E2E TESTS
echo ========================================
echo.
echo Running E2E Admin...
flutter test integration_test\end_to_end\marketplace\admin\marketplace_admin_e2e_test.dart
echo.
echo Running E2E Belanja...
flutter test integration_test\end_to_end\marketplace\warga\belanja_e2e_test.dart
echo.
echo Running E2E Toko Saya...
flutter test integration_test\end_to_end\marketplace\warga\toko_saya_e2e_test.dart
echo.
echo ========================================
echo ALL E2E TESTS COMPLETED!
echo ========================================
goto end

:all_integration
echo.
echo ========================================
echo Running: ALL INTEGRATION TESTS
echo ========================================
echo.
flutter test integration_test\integration\marketplace\marketplace_integration_test.dart
echo.
echo ========================================
echo ALL INTEGRATION TESTS COMPLETED!
echo ========================================
goto end

:all_tests
echo.
echo ========================================
echo Running: ALL MARKETPLACE TESTS
echo ========================================
echo.
echo [1/4] Running E2E Admin...
flutter test integration_test\end_to_end\marketplace\admin\marketplace_admin_e2e_test.dart
echo.
echo [2/4] Running E2E Belanja...
flutter test integration_test\end_to_end\marketplace\warga\belanja_e2e_test.dart
echo.
echo [3/4] Running E2E Toko Saya...
flutter test integration_test\end_to_end\marketplace\warga\toko_saya_e2e_test.dart
echo.
echo [4/4] Running Integration Test...
flutter test integration_test\integration\marketplace\marketplace_integration_test.dart
echo.
echo ========================================
echo ALL MARKETPLACE TESTS COMPLETED!
echo ========================================
goto end

:invalid
echo.
echo [ERROR] Invalid choice!
echo.
goto menu

:exit
echo.
echo Exiting...
exit /b 0

:end
echo.
echo ========================================
echo Test Summary
echo ========================================
echo Check test results above
echo For detailed report, see test output
echo ========================================
echo.
pause
