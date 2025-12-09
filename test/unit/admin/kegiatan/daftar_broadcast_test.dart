import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DummyBroadcast {
  final String judul;
  final String pengirim;
  final DateTime tanggal;
  final String konten;

  DummyBroadcast({
    required this.judul,
    required this.pengirim,
    required this.tanggal,
    required this.konten,
  });
}

class DaftarBroadcastScreen extends StatelessWidget {
  final Stream<List<DummyBroadcast>> stream;

  const DaftarBroadcastScreen({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Broadcast")),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                key: const Key("search_field"),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<DummyBroadcast>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(child: Text("Tidak ada Broadcast"));
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final item = data[i];
                      return ListTile(
                        title: Text(item.judul),
                        subtitle: Text("${item.pengirim} • ${item.tanggal}"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group("Widget Test Daftar Broadcast", () {
    testWidgets("Menampilkan loading saat stream menunggu", (tester) async {
      final controller = StreamController<List<DummyBroadcast>>();

      await tester.pumpWidget(
        DaftarBroadcastScreen(stream: controller.stream),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets("Menampilkan list broadcast", (tester) async {
      final controller = StreamController<List<DummyBroadcast>>();

      await tester.pumpWidget(
        DaftarBroadcastScreen(stream: controller.stream),
      );

      controller.add([
        DummyBroadcast(
          judul: "Pengumuman Penting",
          pengirim: "Pak RT",
          tanggal: DateTime(2025, 1, 1),
          konten: "Besok kerja bakti",
        ),
      ]);

      await tester.pumpAndSettle();

      expect(find.text("Pengumuman Penting"), findsOneWidget);
      expect(find.textContaining("Pak RT"), findsOneWidget);
    });

    testWidgets("Search bar tampil", (tester) async {
      await tester.pumpWidget(
        DaftarBroadcastScreen(
          stream: Stream.value([]),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byKey(const Key("search_field")), findsOneWidget);
    });

    testWidgets("Floating button tampil", (tester) async {
      await tester.pumpWidget(
        DaftarBroadcastScreen(stream: Stream.value([])),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
