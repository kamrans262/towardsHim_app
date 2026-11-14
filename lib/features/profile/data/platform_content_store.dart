import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../auth/data/auth_repository.dart';
import 'about_toward_him_demo_data.dart';

/// Public admin-editable text. Existing assets, layout and onboarding copy stay fixed.
class PlatformContent {
  const PlatformContent({
    required this.welcomeHeading,
    required this.introductionText,
    required this.aboutInformation,
    this.storeUrl,
  });

  final String welcomeHeading;
  final String introductionText;
  final String aboutInformation;
  final String? storeUrl;

  static const defaults = PlatformContent(
    welcomeHeading: 'Welcome to Toward HIM',
    introductionText:
        'Podcasts, Meditations, Prayers, Challenges and a community to help you grow closer to HIM',
    aboutInformation: AboutTowardHimDemoData.description,
  );

  factory PlatformContent.fromApi(Map<String, dynamic> json) => PlatformContent(
        welcomeHeading: json['welcome_heading']?.toString() ?? defaults.welcomeHeading,
        introductionText: json['introduction_text']?.toString() ?? defaults.introductionText,
        aboutInformation: json['about_information']?.toString() ?? defaults.aboutInformation,
        storeUrl: json['store_url']?.toString(),
      );
}

class PlatformContentStore extends ChangeNotifier {
  PlatformContentStore();

  static final PlatformContentStore instance = PlatformContentStore();

  PlatformContent _content = PlatformContent.defaults;
  PlatformContent get content => _content;
  bool _loaded = false;
  Future<void>? _inFlight;

  Future<void> load({bool refresh = false}) {
    if (_loaded && !refresh) return Future.value();
    if (_inFlight != null) return _inFlight!;
    _inFlight = _fetch();
    return _inFlight!.whenComplete(() => _inFlight = null);
  }

  Future<void> _fetch() async {
    try {
      final uri = Uri.parse(AuthRepository.baseUrl + '/content');
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      _content = PlatformContent.fromApi(
        Map<String, dynamic>.from(json['data'] as Map),
      );
      _loaded = true;
      notifyListeners();
    } catch (_) {
      // Retain the approved original wording if the backend is unavailable.
    }
  }
}
