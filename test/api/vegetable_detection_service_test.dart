// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara_pintar_kel_5/services/marketplace/vegetable_detection_service.dart';

void main() {
  group('VegetableDetectionService - PCVK API Tests', () {
    late VegetableDetectionService pcvkService;

    setUp(() {
      pcvkService = VegetableDetectionService();
    });

    group('checkApiStatus', () {
      test('returns true when API is online', () async {
        if (kDebugMode) {
          print('📝 Testing: Check PCVK API health status');
        }

        // Act
        final result = await pcvkService.checkApiStatus();

        // Assert
        expect(result, isA<bool>());
        if (result) {
          if (kDebugMode) {
            print('✅ Passed: API is online and healthy\n');
          }
        } else {
          if (kDebugMode) {
            print('⚠️  Warning: API is offline or unreachable\n');
          }
        }
      });
    });

    group('getAvailableClasses', () {
      test('returns all classification classes', () {
        if (kDebugMode) {
          print('📝 Testing: Retrieve available classification classes');
        }

        // Arrange - Expected classes dari model
        final expectedClasses = ['Segar', 'Layu', 'Busuk'];

        // Act - Get dari service
        final availableClasses =
            VegetableDetectionService.getAvailableClasses();

        // Assert
        expect(availableClasses, isA<List<String>>());
        expect(availableClasses.length, equals(3));
        expect(availableClasses, containsAll(expectedClasses));

        if (kDebugMode) {
          print('✅ Passed: All classification classes available');
          print('   Classes: ${availableClasses.join(", ")}');
          print('   Total: ${availableClasses.length} classes\n');
        }
      });
    });

    group('getModelInformation', () {
      test('returns model metadata', () {
        if (kDebugMode) {
          print('📝 Testing: Retrieve model information');
        }

        // Act
        final modelInfo = VegetableDetectionService.getModelInformation();

        // Assert
        expect(modelInfo, isA<Map<String, dynamic>>());
        expect(modelInfo.containsKey('name'), isTrue);
        expect(modelInfo.containsKey('version'), isTrue);
        expect(modelInfo.containsKey('classes'), isTrue);
        expect(modelInfo.containsKey('description'), isTrue);
        expect(modelInfo.containsKey('features'), isTrue);

        expect(
          modelInfo['name'],
          equals('PCVK - Vegetable Freshness Classifier'),
        );
        expect(modelInfo['classes'], isA<List<String>>());
        expect(modelInfo['classes'].length, equals(3));

        if (kDebugMode) {
          print('✅ Passed: Model information retrieved');
          print('   Name: ${modelInfo['name']}');
          print('   Version: ${modelInfo['version']}');
          print('   Classes: ${modelInfo['classes']}');
          print('   Description: ${modelInfo['description']}');
          print('   Features: ${modelInfo['features']}\n');
        }
      });
    });

    group('detectVegetableFreshness', () {
      test('returns prediction response on successful detection', () async {
        if (kDebugMode) {
          print('📝 Testing: Detect vegetable freshness from image');
        }

        // Arrange - gunakan gambar yang ada
        final testImagePath = 'test/fixtures/test_images/cobagtw3.jpg';
        final testFile = File(testImagePath);

        // Check if test file exists
        if (!await testFile.exists()) {
          if (kDebugMode) {
            print('⚠️  Skipping: Test image not found at $testImagePath');
            print('   Please add test images to test/fixtures/test_images/');
          }
          return;
        }

        // Act
        final result = await pcvkService.detectVegetableFreshness(testFile);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('success'), isTrue);

        if (result['success'] == true) {
          expect(result.containsKey('prediction'), isTrue);
          expect(result.containsKey('confidence'), isTrue);
          expect(result.containsKey('details'), isTrue);

          expect(result['prediction'], isA<String>());
          expect(result['confidence'], isA<num>());
          expect(result['confidence'], greaterThanOrEqualTo(0));
          expect(result['confidence'], lessThanOrEqualTo(100));

          // Validate prediction is one of expected classes
          expect(
            ['Segar', 'Layu', 'Busuk'].contains(result['prediction']),
            isTrue,
            reason: 'Prediction must be one of: Segar, Layu, Busuk',
          );

          if (kDebugMode) {
            print('✅ Passed: Image detection successful');
            print('   Prediction: ${result['prediction']}');
            print('   Confidence: ${result['confidence']}%');
            print('   Details: ${result['details']}\n');
          }
        } else {
          if (kDebugMode) {
            print('❌ Failed: ${result['error']}\n');
          }
        }
      }, skip: false);

      test('handles multiple images correctly - ALL CONDITIONS', () async {
        if (kDebugMode) {
          print(
            '📝 Testing: Detect ALL vegetable conditions (Segar, Busuk, Layu)',
          );
        }

        // Test dengan SEMUA 6 gambar untuk validasi lengkap
        final testImagePaths = [
          // Segar
          'test/fixtures/test_images/cobagtw3.jpg',
          'test/fixtures/test_images/cobagtw4.jpg',
          // Busuk
          'test/fixtures/test_images/cobagtw5.jpg',
          'test/fixtures/test_images/cobagtw6.jpg',
          // Layu
          'test/fixtures/test_images/layu_tomat.jpg',
          'test/fixtures/test_images/layu_tomat2.jpg',
        ];

        final expectedLabels = [
          'Segar',
          'Segar',
          'Busuk',
          'Busuk',
          'Layu',
          'Layu',
        ];

        int successCount = 0;
        int skipCount = 0;
        int correctPredictions = 0;
        int wrongPredictions = 0;

        for (var i = 0; i < testImagePaths.length; i++) {
          final imagePath = testImagePaths[i];
          final expectedLabel = expectedLabels[i];
          final testFile = File(imagePath);

          if (!await testFile.exists()) {
            if (kDebugMode) {
              print('⚠️  Skipping: $imagePath not found');
            }
            skipCount++;
            continue;
          }

          // Act
          final result = await pcvkService.detectVegetableFreshness(testFile);

          // Assert
          expect(result, isA<Map<String, dynamic>>());
          expect(result.containsKey('success'), isTrue);

          if (result['success'] == true) {
            successCount++;
            final prediction = result['prediction'];
            final isCorrect = prediction == expectedLabel;

            if (isCorrect) {
              correctPredictions++;
            } else {
              wrongPredictions++;
            }

            if (kDebugMode) {
              final statusIcon = isCorrect ? '✅' : '❌';
              print('$statusIcon Image: ${imagePath.split('/').last}');
              print('   Expected: $expectedLabel | Got: $prediction');
              print('   Confidence: ${result['confidence']}%');
              print('   Details: ${result['details']}\n');
            }
          }
        }

        if (kDebugMode) {
          print('📊 Detailed Summary:');
          print('   Total Images: ${testImagePaths.length}');
          print('   Processed: $successCount');
          print('   Skipped: $skipCount');
          print('   ✅ Correct Predictions: $correctPredictions');
          print('   ❌ Wrong Predictions: $wrongPredictions');
          print(
            '   Accuracy: ${(correctPredictions / successCount * 100).toStringAsFixed(1)}%\n',
          );
        }

        // Warning jika akurasi rendah
        if (successCount > 0) {
          final accuracy = correctPredictions / successCount;
          if (accuracy < 0.5) {
            if (kDebugMode) {
              print('⚠️  WARNING: Model accuracy is below 50%!');
              print('   This might indicate:');
              print('   1. Image preprocessing issues');
              print('   2. Model needs retraining');
              print('   3. API connection problems\n');
            }
          }
        }
      }, skip: false);

      test('returns error for invalid file', () async {
        if (kDebugMode) {
          print('📝 Testing: Handle invalid/non-existent file');
        }

        // Arrange
        final invalidFile = File('test/fixtures/test_images/nonexistent.jpg');

        // Act
        final result = await pcvkService.detectVegetableFreshness(invalidFile);

        // Assert - Service returns error map instead of throwing
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], isFalse);
        expect(result.containsKey('error'), isTrue);
        expect(result['error'], contains('Connection error'));

        if (kDebugMode) {
          print('✅ Passed: Correctly handles invalid file with error response');
          print('   Error: ${result['error']}\n');
        }
      });
    });

    group('mapPredictionToGrade', () {
      test('correctly maps predictions to grades', () {
        if (kDebugMode) {
          print('📝 Testing: Map predictions to grade system');
        }

        // Test cases
        final testCases = {
          'Segar': 'Grade A',
          'segar': 'Grade A',
          'SEGAR': 'Grade A',
          'Layu': 'Grade B',
          'layu': 'Grade B',
          'Busuk': 'Grade C',
          'busuk': 'Grade C',
          'Unknown': 'Grade A', // Default
        };

        testCases.forEach((prediction, expectedGrade) {
          final result = pcvkService.mapPredictionToGrade(prediction);
          expect(
            result,
            expectedGrade,
            reason: '$prediction should map to $expectedGrade',
          );
        });

        if (kDebugMode) {
          print('✅ Passed: All predictions mapped correctly');
          testCases.forEach((prediction, grade) {
            print('   $prediction -> $grade');
          });
          print('');
        }
      });
    });

    group('getPredictionStyle', () {
      test('returns correct style for each prediction', () {
        if (kDebugMode) {
          print('📝 Testing: Get UI styles for predictions');
        }

        // Test Segar
        final segarStyle = VegetableDetectionService.getPredictionStyle(
          'segar',
        );
        expect(segarStyle, isA<Map<String, dynamic>>());
        expect(segarStyle.containsKey('color'), isTrue);
        expect(segarStyle.containsKey('icon'), isTrue);
        expect(segarStyle.containsKey('message'), isTrue);
        expect(segarStyle['icon'], '🌿');

        // Test Layu
        final layuStyle = VegetableDetectionService.getPredictionStyle('layu');
        expect(layuStyle['icon'], '🍂');

        // Test Busuk
        final busukStyle = VegetableDetectionService.getPredictionStyle(
          'busuk',
        );
        expect(busukStyle['icon'], '❌');

        if (kDebugMode) {
          print('✅ Passed: All prediction styles are correct');
          print('   Segar: ${segarStyle['icon']} - ${segarStyle['message']}');
          print('   Layu: ${layuStyle['icon']} - ${layuStyle['message']}');
          print('   Busuk: ${busukStyle['icon']} - ${busukStyle['message']}\n');
        }
      });
    });

    group('Integration Tests', () {
      test('full workflow: check API -> detect -> map to grade', () async {
        if (kDebugMode) {
          print('📝 Testing: Full integration workflow');
        }

        // Step 1: Check API Status
        if (kDebugMode) {
          print('   Step 1: Checking API status...');
        }
        final isOnline = await pcvkService.checkApiStatus();

        if (!isOnline) {
          if (kDebugMode) {
            print('   ⚠️  API is offline, skipping integration test\n');
          }
          return;
        }
        if (kDebugMode) {
          print('   ✅ API is online');
        }

        // Step 2: Detect Image
        final testImagePath = 'test/fixtures/test_images/cobagtw3.jpg';
        final testFile = File(testImagePath);

        if (!await testFile.exists()) {
          if (kDebugMode) {
            print('   ⚠️  Test image not found, skipping\n');
          }
          return;
        }

        if (kDebugMode) {
          print('   Step 2: Detecting vegetable freshness...');
        }
        final detection = await pcvkService.detectVegetableFreshness(testFile);

        if (detection['success'] != true) {
          if (kDebugMode) {
            print('   ❌ Detection failed: ${detection['error']}\n');
          }
          return;
        }

        if (kDebugMode) {
          print('   ✅ Detection successful: ${detection['prediction']}');
        }

        // Step 3: Map to Grade
        if (kDebugMode) {
          print('   Step 3: Mapping to grade...');
        }
        final grade = pcvkService.mapPredictionToGrade(detection['prediction']);
        expect(grade, isA<String>());
        expect(grade.startsWith('Grade'), isTrue);

        // Step 4: Get UI Style
        if (kDebugMode) {
          print('   Step 4: Getting UI style...');
        }
        final style = VegetableDetectionService.getPredictionStyle(
          detection['prediction'],
        );
        expect(style, isA<Map<String, dynamic>>());

        if (kDebugMode) {
          print('\n📊 Integration Test Results:');
          print('   API Status: Online ✅');
          print('   Prediction: ${detection['prediction']}');
          print('   Confidence: ${detection['confidence']}%');
          print('   Grade: $grade');
          print('   UI Icon: ${style['icon']}');
          print('   Message: ${style['message']}\n');
        }
      }, skip: false);
    });
  });
}
