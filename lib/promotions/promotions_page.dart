import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../services/promotions_service.dart';
import '../widgets/top_bar.dart';
import 'widgets/campaign_card.dart';
import 'widgets/join_campaign_sheet.dart';

/// Promotions section — mobile mirror of the web project's GiftsPage.
/// Lists all active campaigns (giveaways, promotions, gifts).
class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  List<Campaign> _campaigns = [];
  bool _isLoading = true;
  String? _error;
  String _activeTab = 'all';

  static const _tabs = [
    {'key': 'all', 'label': 'Ählisi'},
    {'key': 'giveaway', 'label': 'Bäsleşikler'},
    {'key': 'promotion', 'label': 'Aksiýalar'},
    {'key': 'gift', 'label': 'Sowgatlar'},
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final campaigns = await PromotionsService.listCampaigns(status: 'active');
      if (!mounted) return;
      setState(() {
        _campaigns = campaigns;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Aksiýalary ýükläp bolmady';
        _isLoading = false;
      });
    }
  }

  List<Campaign> get _filtered {
    if (_activeTab == 'all') return _campaigns;
    return _campaigns.where((c) => c.type == _activeTab).toList();
  }

  int _countOf(String type) => _campaigns.where((c) => c.type == type).length;

  Future<void> _openJoin(Campaign c) async {
    final joined = await JoinCampaignSheet.show(context, c);
    if (joined == true) _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: const Color(0xFFDC2626),
          onRefresh: _fetch,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: TopBar()),
              SliverToBoxAdapter(child: _hero()),
              SliverToBoxAdapter(child: _tabBar()),
              _body(),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF7F1D1D), Color(0xFFB91C1C)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'SOWGATLAR WE AKSIÝALAR',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFCA5A5),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gatnaş, ýeň we sowgat al',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, height: 1.15),
          ),
          const SizedBox(height: 10),
          const Text(
            'Wagtlaýyn bäsleşiklere we aksiýalara gatnaşyp, gymmat bahaly sowgatlary gazanyň',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xCCFFFFFF), height: 1.4),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stat(Icons.emoji_events_outlined, _countOf('giveaway'), 'Bäsleşik'),
              const SizedBox(width: 10),
              _stat(Icons.sell_outlined, _countOf('promotion'), 'Aksiýa'),
              const SizedBox(width: 10),
              _stat(Icons.card_giftcard_outlined, _countOf('gift'), 'Sowgat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, int count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: const Color(0xFFFBBF24)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF), height: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      height: 56,
      color: const Color(0xFFF5F5F5),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tab = _tabs[i];
          final active = _activeTab == tab['key'];
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab['key']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? const Color(0xFFDC2626) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: active ? const Color(0xFFDC2626) : const Color(0xFFE5E7EB)),
              ),
              child: Text(
                tab['label']!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF4B5563),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFDC2626))),
      );
    }
    if (_error != null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _emptyState(Icons.wifi_off_outlined, _error!, showRetry: true),
      );
    }
    final items = _filtered;
    if (items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _emptyState(Icons.card_giftcard_outlined, 'Häzirlikçe açyk aksiýa ýok'),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => CampaignCard(campaign: items[i], onJoin: () => _openJoin(items[i])),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String message, {bool showRetry = false}) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
          if (showRetry) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _fetch,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Gaýtadan synanyş'),
            ),
          ],
        ],
      ),
    );
  }
}
