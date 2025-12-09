# Release Notes - Version 1.10.0

**Enhancements:**

* **Streamlined Financial Reporting:**
  Refactored `LaporanKeuanganModel` by removing unnecessary formatting for total income and expenses, simplifying the data structure and improving performance.

* **WargaTagihanModel Improvements:**
  Enhanced the `WargaTagihanModel` to include additional fields such as `alamat`, `bukti` (proof of payment), and `catatan` (notes). Additionally, updated the data fetching logic from Supabase to support these new fields, providing a more comprehensive view of the tagihan (billing) data.

* **UI Improvements:**
  Updated various UI components across different screens to reflect the latest changes in financial data handling, including:

  * Improved error handling for image uploads, ensuring a better user experience when uploading proof of payment images.
  * Visual adjustments to the `Tagihan` section, ensuring consistency and clarity in displaying financial information.

**Refactor:**

* **Refactored Payment Screens:**
  Refactored the `PengeluaranTambahScreen` and `FormPembayaranScreen` to utilize new methods for saving and uploading payment evidence. This refactor improves the structure of payment handling and simplifies future updates or feature additions.

**Bug Fixes:**

* Fixed issues related to image upload failures, ensuring smoother interactions with proof of payment images.
