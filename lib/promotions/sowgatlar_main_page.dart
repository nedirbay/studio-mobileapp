import 'package:flutter/material.dart';
import '../services/promotions_service.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../models/campaign.dart';
import '../identity/profile_page.dart';
import '../widgets/top_bar.dart';
import '../widgets/app_header.dart';
import 'package:intl/intl.dart';

class SowgatlarMainPage extends StatefulWidget {
  final int initialTab;

  const SowgatlarMainPage({super.key, this.initialTab = 0});

  @override
  State<SowgatlarMainPage> createState() => _SowgatlarMainPageState();
}

class _SowgatlarMainPageState extends State<SowgatlarMainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        final isDark = settings.isDarkMode;
        final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
        final navBgColor = isDark ? const Color(0xFF1F2937) : Colors.white;

        final List<Widget> children = [
          const _GiftsTabBody(),
          const ProfilePage(),
        ];

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                if (_currentIndex == 0) ...[
                  const TopBar(),
                  const AppHeader(),
                ],
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: children,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: navBgColor,
              selectedItemColor: const Color(0xFFDC2626), // brand color
              unselectedItemColor: isDark ? Colors.grey[550] ?? Colors.grey[500] : const Color(0xFF9CA3AF),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.card_giftcard_outlined), activeIcon: const Icon(Icons.card_giftcard_rounded), label: settings.translate('gifts_tab')),
                BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person_rounded), label: settings.translate('profile_tab')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GiftsTabBody extends StatefulWidget {
  const _GiftsTabBody();

  @override
  State<_GiftsTabBody> createState() => _GiftsTabBodyState();
}

class _GiftsTabBodyState extends State<_GiftsTabBody> {
  List<Campaign> _campaigns = [];
  bool _isLoading = true;
  String? _error;

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
      final res = await PromotionsService.listCampaigns(status: 'active');
      if (!mounted) return;
      setState(() {
        _campaigns = res;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = SettingsService().translate('error_campaigns');
          _isLoading = false;
        });
      }
    }
  }

  void _openJoinDialog(Campaign campaign, SettingsService settings) {
    if (!AuthService().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(settings.translate('login_required_join'))),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _JoinCampaignFormSheet(
        campaign: campaign,
        onSuccess: _fetch,
        settings: settings,
      ),
    );
  }

  String _formatCampaignDuration(Campaign c, String langCode) {
    final Map<String, List<String>> localizedMonths = {
      'TM': [
        'ýanwar', 'fewral', 'mart', 'aprel', 'maý', 'iýun',
        'iýul', 'awgust', 'sentýabr', 'oktýabr', 'noýabr', 'dekabr'
      ],
      'RU': [
        'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
        'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
      ],
      'EN': [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ]
    };
    final months = localizedMonths[langCode] ?? localizedMonths['TM']!;

    final startDate = DateTime.tryParse(c.startsAt);
    if (startDate == null) {
      return langCode == 'TM' ? 'Möhletsiz' : (langCode == 'RU' ? 'Бессрочно' : 'Unlimited');
    }
    
    final endDate = c.endsAt != null ? DateTime.tryParse(c.endsAt!) : null;
    if (endDate == null) {
      if (langCode == 'TM') return '${startDate.day} ${months[startDate.month - 1]} ${startDate.year} senesinden başlap';
      if (langCode == 'RU') return 'С ${startDate.day} ${months[startDate.month - 1]} ${startDate.year} года';
      return 'Starting from ${months[startDate.month - 1]} ${startDate.day}, ${startDate.year}';
    }
    
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      if (langCode == 'TM') return '${startDate.day}-${endDate.day} ${months[startDate.month - 1]} ${startDate.year} aralyk dowam etýär';
      if (langCode == 'RU') return 'Период проведения: ${startDate.day}-${endDate.day} ${months[startDate.month - 1]} ${startDate.year}';
      return 'Running from ${months[startDate.month - 1]} ${startDate.day} to ${endDate.day}, ${startDate.year}';
    }
    
    if (startDate.year == endDate.year) {
      if (langCode == 'TM') return '${startDate.day} ${months[startDate.month - 1]} - ${endDate.day} ${months[endDate.month - 1]} ${startDate.year} aralyk dowam etýär';
      if (langCode == 'RU') return 'Период проведения: ${startDate.day} ${months[startDate.month - 1]} - ${endDate.day} ${months[endDate.month - 1]} ${startDate.year}';
      return 'Running from ${months[startDate.month - 1]} ${startDate.day} to ${months[endDate.month - 1]} ${endDate.day}, ${startDate.year}';
    }
    
    if (langCode == 'RU') {
      return '${startDate.day} ${months[startDate.month - 1]} ${startDate.year} - ${endDate.day} ${months[endDate.month - 1]} ${endDate.year}';
    }
    if (langCode == 'EN') {
      return '${months[startDate.month - 1]} ${startDate.day}, ${startDate.year} - ${months[endDate.month - 1]} ${endDate.day}, ${endDate.year}';
    }
    return '${startDate.day} ${months[startDate.month - 1]} ${startDate.year} - ${endDate.day} ${months[endDate.month - 1]} ${endDate.year}';
  }

  Widget _buildTypeBadge(String type, String langCode) {
    String label = 'Aksiýa';
    Color color = const Color(0xFFDC2626);
    IconData icon = Icons.star_outline_rounded;

    if (type == 'giveaway') {
      label = langCode == 'TM' ? 'Bäsleşik' : (langCode == 'RU' ? 'Конкурс' : 'Contest');
      color = const Color(0xFFDC2626);
      icon = Icons.emoji_events_outlined;
    } else if (type == 'promotion') {
      label = langCode == 'TM' ? 'Aksiýa' : (langCode == 'RU' ? 'Акция' : 'Promotion');
      color = const Color(0xFFF59E0B);
      icon = Icons.local_offer_outlined;
    } else if (type == 'gift') {
      label = langCode == 'TM' ? 'Sowgat' : (langCode == 'RU' ? 'Подарок' : 'Gift');
      color = const Color(0xFF7C3AED);
      icon = Icons.card_giftcard_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService(),
      builder: (context, _) {
        final settings = SettingsService();
        final isDark = settings.isDarkMode;
        final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
        final borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
        final scaffoldBg = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);

        if (_isLoading) {
          return Center(
            child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.black),
          );
        }
        if (_error != null) return _buildError(_error!, settings);
        
        return Scaffold(
          backgroundColor: scaffoldBg,
          body: RefreshIndicator(
            onRefresh: _fetch,
            color: const Color(0xFFDC2626),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                            ? [const Color(0xFF0F172A), const Color(0xFF111827)] 
                            : [const Color(0xFF0F172A), const Color(0xFF1E1B4B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(settings.translate('welcome_promos').toUpperCase(), style: const TextStyle(color: Color(0xFFFDA4AF), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text(settings.translate('welcome_gifts'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
                        const SizedBox(height: 8),
                        Text(settings.translate('promos_desc'), style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  
                  if (_campaigns.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(settings.translate('no_campaigns'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _campaigns.length,
                      itemBuilder: (context, index) {
                        final c = _campaigns[index];
                        final createdStr = c.createdAt != null ? DateFormat('dd.MM.yyyy').format(DateTime.parse(c.createdAt!)) : '-';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Banner image placeholder or cover
                              if (c.imageUrl != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(23.5)),
                                  child: Image.network(
                                    c.imageUrl!,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(height: 160, color: borderColor),
                                  ),
                                )
                              else
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: c.getGradientColors(),
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(23.5)),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.card_giftcard_outlined, size: 48, color: Colors.white),
                                  ),
                                ),
                              
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTypeBadge(c.type, settings.languageCode),
                                    const SizedBox(height: 12),
                                    Text(
                                      c.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 18, 
                                        color: isDark ? Colors.white : const Color(0xFF111827), 
                                        height: 1.2
                                      ),
                                    ),
                                    if (c.subtitle != null && c.subtitle!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(c.subtitle!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                    ],
                                    const SizedBox(height: 16),
                                    
                                    // Prize / Discount Details
                                    Text(settings.translate('what_given'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                                    const SizedBox(height: 6),
                                    if (c.prizeTitle != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF332A15) : const Color(0xFFFFFBEB), 
                                          borderRadius: BorderRadius.circular(12), 
                                          border: Border.all(color: isDark ? const Color(0xFF5E491A) : const Color(0xFFFDE68A)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.emoji_events, color: Color(0xFFD97706), size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                c.prizeTitle!, 
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold, 
                                                  color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF78350F)
                                                ),
                                              ),
                                            ),
                                            if (c.prizeValue != null && double.tryParse(c.prizeValue.toString()) != null && double.parse(c.prizeValue.toString()) > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xFF111827) : Colors.white, 
                                                  borderRadius: BorderRadius.circular(6)
                                                ),
                                                child: Text('${c.prizeValue} TMT', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFB45309))),
                                              ),
                                          ],
                                        ),
                                      ),
                                    if (c.discountPercent != null && c.discountPercent! > 0) ...[
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
                                            child: Text('${c.discountPercent}% ${settings.languageCode == 'TM' ? 'arzanladyş' : (settings.languageCode == 'RU' ? 'скидка' : 'discount')}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                          ),
                                          if (c.promoCode != null) ...[
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC), 
                                                border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFCBD5E1)), 
                                                borderRadius: BorderRadius.circular(8)
                                              ),
                                              child: Text(c.promoCode!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    if (c.description != null)
                                      Text(
                                        c.description!, 
                                        style: TextStyle(
                                          fontSize: 13, 
                                          color: isDark ? Colors.grey[300] : const Color(0xFF475569), 
                                          height: 1.4
                                        ),
                                      ),

                                    const SizedBox(height: 16),
                                    Divider(color: borderColor),
                                    const SizedBox(height: 12),
                                    
                                    // Rules Section
                                    Text(settings.translate('what_do'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                                    const SizedBox(height: 8),
                                    if (c.rulesList != null && c.rulesList!.isNotEmpty)
                                      ...c.rulesList!.map((r) => Padding(
                                        padding: const EdgeInsets.only(bottom: 6.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                r.text, 
                                                style: TextStyle(
                                                  fontSize: 13, 
                                                  color: isDark ? Colors.grey[300] : const Color(0xFF334155)
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                    else if (c.rules != null && c.rules!.isNotEmpty)
                                      Text(
                                        c.rules!, 
                                        style: TextStyle(
                                          fontSize: 13, 
                                          color: isDark ? Colors.grey[300] : const Color(0xFF334155)
                                        ),
                                      )
                                    else
                                      Row(
                                        children: [
                                          const Icon(Icons.info_outline, color: Color(0xFF64748B), size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              settings.languageCode == 'TM' 
                                                  ? 'Programma agza bolup gatnaşmak ýeterlik.' 
                                                  : (settings.languageCode == 'RU' 
                                                      ? 'Достаточно зарегистрироваться в приложении.' 
                                                      : 'Just registering in the app is enough.'),
                                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)
                                            ),
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 16),
                                    
                                    // Metadata (Starts/Ends, Posted Date)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC), 
                                        borderRadius: BorderRadius.circular(12), 
                                        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9))
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF3B82F6)),
                                              const SizedBox(width: 8),
                                              Expanded(child: Text(_formatCampaignDuration(c, settings.languageCode), style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.bold))),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                              const SizedBox(width: 8),
                                              Text('${settings.translate('posted_date')} $createdStr', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Join Action Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: c.joinedByMe == true
                                          ? OutlinedButton.icon(
                                              onPressed: null,
                                              icon: const Icon(Icons.check, color: Colors.green),
                                              label: Text(settings.translate('joined'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                            )
                                          : ElevatedButton(
                                              onPressed: c.isActive ? () => _openJoinDialog(c, settings) : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFDC2626),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: Text(c.isActive ? settings.translate('join') : settings.translate('ended'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(String msg, SettingsService settings) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _fetch,
              child: Text(settings.translate('try_again')),
            )
          ],
        ),
      );
}

class _JoinCampaignFormSheet extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback onSuccess;
  final SettingsService settings;

  const _JoinCampaignFormSheet({
    required this.campaign, 
    required this.onSuccess,
    required this.settings,
  });

  @override
  State<_JoinCampaignFormSheet> createState() => _JoinCampaignFormSheetState();
}

class _JoinCampaignFormSheetState extends State<_JoinCampaignFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+993');
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService().user;
    if (user != null) {
      _nameController.text = user['username'] ?? '';
      _emailController.text = user['email'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await PromotionsService.join(
        widget.campaign.id,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.settings.translate('success_joined')), 
          backgroundColor: Colors.green
        ),
      );
      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.settings.translate('try_again')}: $e'), backgroundColor: const Color(0xFFDC2626)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.settings.isDarkMode;
    final sheetBgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final fieldBgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);

    return Container(
      decoration: BoxDecoration(
        color: sheetBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.settings.translate('join_promo'), 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w900, 
                      color: isDark ? Colors.white : const Color(0xFF111827)
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black), 
                    onPressed: () => Navigator.pop(context)
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(widget.settings.translate('full_name'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: widget.settings.translate('write_name'), 
                  filled: true, 
                  fillColor: fieldBgColor, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                ),
                validator: (value) => value!.isEmpty ? widget.settings.translate('write_name') : null,
              ),
              const SizedBox(height: 16),
              
              Text(widget.settings.translate('phone_number'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: widget.settings.translate('write_phone'), 
                  filled: true, 
                  fillColor: fieldBgColor, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                ),
                validator: (value) => value!.isEmpty ? widget.settings.translate('write_phone') : null,
              ),
              const SizedBox(height: 16),
              
              Text(widget.settings.translate('email'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'mysal@gmail.com', 
                  filled: true, 
                  fillColor: fieldBgColor, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                ),
              ),
              const SizedBox(height: 16),
              
              Text(widget.settings.translate('note'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: widget.settings.translate('write_note'), 
                  filled: true, 
                  fillColor: fieldBgColor, 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitJoin,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.settings.translate('join'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
