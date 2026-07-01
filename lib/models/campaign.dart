import 'package:flutter/material.dart';
import '../config.dart';

/// Campaign / promotion item. Mirrors the `Campaign` type used by the
/// studio-front web project (`gifts/campaigns/` API).
class CampaignRule {
  final int id;
  final String text;
  final int order;

  CampaignRule({required this.id, required this.text, required this.order});

  factory CampaignRule.fromJson(Map<String, dynamic> json) {
    return CampaignRule(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      text: (json['text'] ?? '').toString(),
      order: json['order'] is int ? json['order'] : int.tryParse('${json['order']}') ?? 0,
    );
  }
}

/// Campaign type: 'giveaway' (bäsleşik), 'promotion' (aksiýa), 'gift' (sowgat).
class Campaign {
  final int id;
  final String type;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? bannerUrl;
  final String? prizeTitle;
  final num? prizeValue;
  final String startsAt;
  final String? endsAt;
  final String? rules;
  final num? minOrderAmount;
  final int? discountPercent;
  final String? promoCode;
  final String? bgGradient;
  final bool isFeatured;
  final String status;
  final List<CampaignRule> rulesList;
  final int participantsCount;
  final bool isActive;
  final bool joinedByMe;
  final int? timeLeftSeconds;
  final String? createdAt;

  Campaign({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.bannerUrl,
    this.prizeTitle,
    this.prizeValue,
    required this.startsAt,
    this.endsAt,
    this.rules,
    this.minOrderAmount,
    this.discountPercent,
    this.promoCode,
    this.bgGradient,
    this.isFeatured = false,
    required this.status,
    this.rulesList = const [],
    this.participantsCount = 0,
    this.isActive = false,
    this.joinedByMe = false,
    this.timeLeftSeconds,
    this.createdAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    num? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    final rawRules = json['rules_list'];
    final rulesList = (rawRules is List)
        ? rawRules
            .whereType<Map>()
            .map((e) => CampaignRule.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <CampaignRule>[];

    return Campaign(
      id: parseInt(json['id']) ?? 0,
      type: (json['type'] ?? 'promotion').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      bannerUrl: json['banner_url']?.toString(),
      prizeTitle: json['prize_title']?.toString(),
      prizeValue: parseNum(json['prize_value']),
      startsAt: (json['starts_at'] ?? '').toString(),
      endsAt: json['ends_at']?.toString(),
      rules: json['rules']?.toString(),
      minOrderAmount: parseNum(json['min_order_amount']),
      discountPercent: parseInt(json['discount_percent']),
      promoCode: json['promo_code']?.toString(),
      bgGradient: json['bg_gradient']?.toString(),
      isFeatured: json['is_featured'] == true,
      status: (json['status'] ?? 'active').toString(),
      rulesList: rulesList,
      participantsCount: parseInt(json['participants_count']) ?? 0,
      isActive: json['is_active'] == true,
      joinedByMe: json['joined_by_me'] == true,
      timeLeftSeconds: parseInt(json['time_left_seconds']),
      createdAt: json['created_at']?.toString(),
    );
  }

  /// Resolves a possibly-relative media path to an absolute URL.
  static String? resolveMedia(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http') || url.startsWith('blob:') || url.startsWith('data:')) {
      return url;
    }
    return '${Config.mediaBaseUrl}${url.startsWith('/') ? '' : '/'}$url';
  }

  String? get resolvedImage => resolveMedia(imageUrl);
  String? get resolvedBanner => resolveMedia(bannerUrl);

  List<Color> getGradientColors() {
    if (bgGradient == null || bgGradient!.isEmpty) {
      return [const Color(0xFFDC2626), const Color(0xFFF97316)];
    }
    if (bgGradient!.contains(',')) {
      final parts = bgGradient!.split(',');
      final c1 = _parseColor(parts[0], const Color(0xFFDC2626));
      final c2 = _parseColor(parts[1], const Color(0xFFF97316));
      return [c1, c2];
    }
    final c = _parseColor(bgGradient!, const Color(0xFFDC2626));
    return [c, c];
  }

  static Color _parseColor(String hex, Color fallback) {
    hex = hex.trim().replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(val);
    }
    return fallback;
  }
}
