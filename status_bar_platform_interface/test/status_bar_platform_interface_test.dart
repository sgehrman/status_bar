import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_platform_interface/status_bar_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group('$status_barPlatform', () {
    test('$MethodChannelstatus_bar is the default instance', () {
      expect(status_barPlatform.instance, isA<MethodChannelstatus_bar>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        status_barPlatform.instance = Implementsstatus_barPlatform();
      }, throwsA(isA<Error>()));
    });

    test('Can be extended', () {
      status_barPlatform.instance = Extendsstatus_barPlatform();
    });

    test('Can be mocked with `implements`', () {
      status_barPlatform.instance = ImplementsWithIsMock();
    });
  });
}

class ImplementsWithIsMock extends Mock
    with MockPlatformInterfaceMixin
    implements status_barPlatform {}

class Implementsstatus_barPlatform extends Mock
    implements status_barPlatform {}

class Extendsstatus_barPlatform extends status_barPlatform {}