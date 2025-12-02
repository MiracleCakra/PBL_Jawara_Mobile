# Release Notes - Version 1.3.0

## 🚀 New Features:

* **Supabase Integration for Data Management**:

  * Integrated Supabase client for dynamic data handling across multiple pages.
  * Replaced static family data with dynamic data from Supabase in **DaftarMutasiKeluargaPage**.
  * Enabled real-time family member data fetching in **DetailKeluargaPage** via Supabase.
  * Enhanced **TambahMutasiKeluargaPage** to dynamically load family names from Supabase.
  * Updated **DaftarRumahPage** to fetch house data dynamically from Supabase.

* **House Management Updates**:

  * Implemented house record deletion in **DetailRumahPage** using Supabase.
  * Added house editing functionality in **EditRumahPage** with Supabase integration.
  * Enabled house creation in **TambahRumahPage** through Supabase.

* **CI/CD Pipeline**:

  * Introduced automated CI/CD pipelines for continuous testing and APK building.

## 🐛 Bug Fixes:

* Fixed issue with versioning and distribution that caused incorrect versioning in the APK.
* Resolved minor UI bug affecting the home screen layout on Android devices.

## 🔧 Miscellaneous:

* Updated release notes to reflect new features and improvements in version 1.3.0.
* Updated dependencies for better performance and security.
* Improved build times by optimizing Flutter build configurations.

<!-- For more details, visit our [documentation](https://link-to-docs.com). -->
