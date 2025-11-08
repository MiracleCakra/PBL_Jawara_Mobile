import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:jawara_pintar_kel_5/utils.dart'
    show formatDate, getPrimaryColor, openDateTimePicker;
import 'package:jawara_pintar_kel_5/widget/moon_result_modal.dart'
    show showResultModal, ResultType;

class CetakLaporanScreen extends StatefulWidget {
  const CetakLaporanScreen({super.key});

  @override
  State<CetakLaporanScreen> createState() => _CetakLaporanScreenState();
}

class _CetakLaporanScreenState extends State<CetakLaporanScreen> {
  String _selectedType = 'pemasukan';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors ?? MoonTokens.light.colors;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left, color: Colors.black),
        ),
        title: Text(
          'Cetak Laporan',
          style: MoonTokens.light.typography.heading.text20.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Text(
              'Cetak atau ekspor laporan keuangan',
              style: MoonTokens.light.typography.body.text14.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            // Form card
            Container(
              width: double.infinity,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: MoonSquircleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ).squircleBorderRadius(context),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenis Laporan',
                    style: MoonTokens.light.typography.body.text16.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TypeSegmented(
                    value: _selectedType,
                    onChanged: (v) => setState(() => _selectedType = v),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Periode',
                    style: MoonTokens.light.typography.body.text16.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Dari tanggal',
                          value: _startDate == null
                              ? null
                              : formatDate(_startDate!),
                          onTap: () async {
                            final picked = await openDateTimePicker(context);
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'Sampai tanggal',
                          value: _endDate == null
                              ? null
                              : formatDate(_endDate!),
                          onTap: () async {
                            final picked = await openDateTimePicker(context);
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: MoonFilledButton(
                          backgroundColor: getPrimaryColor(context),
                          onTap: _printReport,
                          label: const Text('Cetak'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _periodLabel {
    if (_startDate == null && _endDate == null) return 'Semua waktu';
    if (_startDate != null && _endDate == null) {
      return 'Sejak ${formatDate(_startDate!)}';
    }
    if (_startDate == null && _endDate != null) {
      return 'Hingga ${formatDate(_endDate!)}';
    }
    return '${formatDate(_startDate!)} - ${formatDate(_endDate!)}';
  }

  String _labelForType(String v) {
    switch (v) {
      case 'pemasukan':
        return 'Pemasukan';
      case 'pengeluaran':
        return 'Pengeluaran';
      default:
        return 'Semua';
    }
  }

  Future<void> _printReport() async {
    await showResultModal(
      context,
      type: ResultType.success,
      title: 'Laporan siap!',
      description:
          'Laporan ${_labelForType(_selectedType).toLowerCase()} untuk periode $_periodLabel berhasil disiapkan.',
      actionLabel: 'Selesai',
      onAction: () {},
    );
  }
}

class _TypeSegmented extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TypeSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.moonColors ?? MoonTokens.light.colors;
    final items = const [
      ('pemasukan', 'Pemasukan'),
      ('pengeluaran', 'Pengeluaran'),
      ('semua', 'Semua'),
    ];

    return Container(
      decoration: ShapeDecoration(
        color: Colors.grey[50],
        shape: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(12).squircleBorderRadius(context),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (final (key, label) in items) ...[
            Expanded(
              child: _Segment(
                label: label,
                selected: value == key,
                onTap: () => onChanged(key),
                selectedColor: colors.piccolo,
              ),
            ),
            if (key != items.last.$1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? selectedColor.withValues(alpha: 0.12)
          : Colors.transparent,
      shape: MoonSquircleBorder(
        borderRadius: BorderRadius.circular(10).squircleBorderRadius(context),
      ),
      child: InkWell(
        customBorder: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(10).squircleBorderRadius(context),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: MoonTokens.light.typography.body.text14.copyWith(
                color: selected ? selectedColor : Colors.black,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: MoonSquircleBorder(
        borderRadius: BorderRadius.circular(12).squircleBorderRadius(context),
      ),
      child: InkWell(
        customBorder: MoonSquircleBorder(
          borderRadius: BorderRadius.circular(12).squircleBorderRadius(context),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.event_outlined, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value ?? label,
                  style: MoonTokens.light.typography.body.text14.copyWith(
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
