import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/campaign.dart';

/// Visual metadata per campaign type, matching the web GiftsPage palette.
class CampaignTypeMeta {
  final String label;
  final Color color;
  final IconData icon;
  const CampaignTypeMeta(this.label, this.color, this.icon);

  static const Map<String, CampaignTypeMeta> _map = {
    'giveaway': CampaignTypeMeta('Bäsleşik', Color(0xFFDC2626), Icons.emoji_events_outlined),
    'promotion': CampaignTypeMeta('Aksiýa', Color(0xFFF59E0B), Icons.sell_outlined),
    'gift': CampaignTypeMeta('Sowgat', Color(0xFF7C3AED), Icons.card_giftcard_outlined),
  };

  static CampaignTypeMeta of(String type) =>
      _map[type] ?? const CampaignTypeMeta('Aksiýa', Color(0xFFF59E0B), Icons.sell_outlined);
}

String countdownLabel(int? seconds) {
  if (seconds == null) return 'Möhletsiz';
  if (seconds <= 0) return 'Tamamlandy';
  final d = seconds ~/ 86400;
  final h = (seconds % 86400) ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (d > 0) return '$d gün $h sag galdy';
  if (h > 0) return '$h sag $m min galdy';
  return '$m min galdy';
}

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback onJoin;

  const CampaignCard({super.key, required this.campaign, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final meta = CampaignTypeMeta.of(campaign.type);
    final image = campaign.resolvedImage;
    final urgent = campaign.isActive &&
        campaign.timeLeftSeconds != null &&
        campaign.timeLeftSeconds! > 0 &&
        campaign.timeLeftSeconds! < 86400;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: image != null
                      ? Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _placeholder(meta),
                        )
                      : _placeholder(meta),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _badge(meta.label, meta.color, icon: meta.icon),
              ),
              if (!campaign.isActive)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _badge('Tamamlandy', const Color(0xFF6B7280)),
                )
              else if (urgent)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _badge('Tiz tamamlanýar', const Color(0xFFDC2626)),
                ),
            ],
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                ),
                if (campaign.subtitle != null && campaign.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    campaign.subtitle!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
                  ),
                ],
                if (campaign.prizeTitle != null && campaign.prizeTitle!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, size: 18, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          campaign.prizeTitle!,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                        ),
                      ),
                      if (campaign.prizeValue != null && campaign.prizeValue! > 0)
                        Text(
                          '${campaign.prizeValue} TMT',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                        ),
                    ],
                  ),
                ],
                if (campaign.discountPercent != null && campaign.discountPercent! > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${campaign.discountPercent}% arzanladyş',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                        ),
                      ),
                      if (campaign.promoCode != null && campaign.promoCode!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _promoCode(context, campaign.promoCode!),
                      ],
                    ],
                  ),
                ],
                if (campaign.rulesList.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...campaign.rulesList.take(4).map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  r.text,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ] else if (campaign.rules != null && campaign.rules!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    campaign.rules!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 15, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 5),
                    Text(
                      countdownLabel(campaign.timeLeftSeconds),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.people_outline, size: 15, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 5),
                    Text(
                      '${campaign.participantsCount} gatnaşyjy',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: campaign.joinedByMe
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Gatnaşdyňyz'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            side: const BorderSide(color: Color(0xFFD1FAE5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: campaign.isActive ? onJoin : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFE5E7EB),
                            disabledForegroundColor: const Color(0xFF9CA3AF),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            campaign.isActive ? 'Gatnaş' : 'Tamamlandy',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(CampaignTypeMeta meta) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [meta.color, meta.color.withValues(alpha: 0.6)],
        ),
      ),
      child: Center(child: Icon(meta.icon, size: 56, color: Colors.white.withValues(alpha: 0.9))),
    );
  }

  Widget _badge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _promoCode(BuildContext context, String code) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promo kod kopirlendi: $code')),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer_outlined, size: 13, color: Color(0xFF6B7280)),
            const SizedBox(width: 4),
            Text(
              code,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
            ),
          ],
        ),
      ),
    );
  }
}
