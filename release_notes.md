# Release Notes - Version 1.5.2

🚀 **New Features**:

* **Iuran and Tagihan Features**:

  * Implemented new iuran and tagihan management functionality.
  * **iuran_model**: Manages iuran data and operations with Supabase integration.

    * Fetch, save, and edit iuran data.
    * Fetch iuran names for tagihan creation.
    * Save tagihan for all families.
  * **tagihan_model**: Manages tagihan data and operations with Supabase integration.

    * Fetch tagihan data for streamlined management.

* **Detail Tagihan Screen**:

  * Added functionality for approving and rejecting payments via Supabase integration.

* **Edit Iuran Screen**:

  * Improved screen to allow real-time editing of iuran data synced with Supabase.

* **Kategori Iuran Screen**:

  * Now dynamically fetches iuran data from Supabase for up-to-date information.

* **Tagih Iuran Screen**:

  * Optimized process to tagih iuran for all families with improved backend support.

* **Tagihan Screen**:

  * Updated to fetch tagihan data directly from Supabase for better data consistency.

* **Tambah Iuran Screen**:

  * Enhanced for adding new iuran data to Supabase, improving user experience.

🐛 **Bug Fixes**:

* Fixed multiple alignment issues across various admin and management screens.
* Corrected misaligned widgets on smaller devices.
* Resolved overflow text and inconsistent spacing in certain areas.

🔧 **Miscellaneous**:

* Refactored code across iuran and tagihan-related pages for better structure and easier maintenance.
* Updated Supabase integration for better data handling and improved system performance.
