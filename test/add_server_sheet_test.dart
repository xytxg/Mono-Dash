import 'package:flutter_test/flutter_test.dart';
import 'package:mono_dash/core/utils/server_host_normalizer.dart';

void main() {
  group('normalizeServerHostInput', () {
    test('keeps plain host input', () {
      expect(normalizeServerHostInput('example.com'), 'example.com');
      expect(normalizeServerHostInput('192.168.1.10'), '192.168.1.10');
    });

    test('strips scheme and url parts', () {
      expect(
        normalizeServerHostInput('https://example.com:10000/api?x=1#top'),
        'example.com',
      );
      expect(normalizeServerHostInput('http://ssss/'), 'ssss');
    });

    test('handles full-width colon in scheme', () {
      expect(
        normalizeServerHostInput('https：//example.com/path'),
        'example.com',
      );
      expect(normalizeServerHostInput('http：//ssss/'), 'ssss');
    });

    test('strips port from host-like input', () {
      expect(normalizeServerHostInput('example.com:10000'), 'example.com');
      expect(
        normalizeServerHostInput('192.168.1.10:10000/login'),
        '192.168.1.10',
      );
    });
  });
}
