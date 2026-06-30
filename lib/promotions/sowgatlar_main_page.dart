import 'package:flutter/material.dart';
import '../services/promotions_service.dart';
import '../services/auth_service.dart';
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
    final List<Widget> children = [
      const _GiftsTabBody(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFDC2626), // brand color
          unselectedItemColor: const Color(0xFF9CA3AF),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), activeIcon: Icon(Icons.card_giftcard_rounded), label: 'Sowgatlar'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
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
          _error = 'Kampaniýalary ýükläp bolmady';
          _isLoading = false;
        });
      }
    }
  }

  void _openJoinDialog(Campaign campaign) {
    if (!AuthService().isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aksiýa gatnaşmak üçin ilki hasabyňyza giriň.')),
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
      ),
    );
  }

  String _formatCampaignDuration(Campaign c) {
    final months = [
      'ýanwar', 'fewral', 'mart', 'aprel', 'maý', 'iýun',
      'iýul', 'awgust', 'sentýabr', 'oktýabr', 'noýabr', 'dekabr'
    ];
    final startDate = DateTime.tryParse(c.startsAt);
    if (startDate == null) return 'Möhletsiz';
    
    final endDate = c.endsAt != null ? DateTime.tryParse(c.endsAt!) : null;
    if (endDate == null) {
      return '${startDate.day} ${months[startDate.month - 1]} ${startDate.year} senesinden başlap';
    }
    
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '${startDate.day}-${endDate.day} ${months[startDate.month - 1]} ${startDate.year} aralyk dowam etýär';
    }
    
    if (startDate.year == endDate.year) {
      return '${startDate.day} ${months[startDate.month - 1]} - ${endDate.day} ${months[endDate.month - 1]} ${startDate.year} aralyk dowam etýär';
    }
    
    return '${startDate.day} ${months[startDate.month - 1]} ${startDate.year} - ${endDate.day} ${months[endDate.month - 1]} ${endDate.year}';
  }

  Widget _buildTypeBadge(String type) {
    String label = 'Aksiýa';
    Color color = const Color(0xFFDC2626);
    IconData icon = Icons.star_outline_rounded;

    if (type == 'giveaway') {
      label = 'Bäsleşik';
      color = const Color(0xFFDC2626);
      icon = Icons.emoji_events_outlined;
    } else if (type == 'promotion') {
      label = 'Aksiýa';
      color = const Color(0xFFF59E0B);
      icon = Icons.local_offer_outlined;
    } else if (type == 'gift') {
      label = 'Sowgat';
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
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black));
    if (_error != null) return _buildError(_error!);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Höweslendiriş Aksiýalary', style: TextStyle(color: Color(0xFFFDA4AF), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
                    SizedBox(height: 8),
                    Text('Sowgatlar we Mümkinçilikler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
                    SizedBox(height: 8),
                    Text('Doganlar programmasyndan peýdalanyjylar üçin ýörite bäsleşikler, sowgatlar we aksiýalar.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
              
              if (_campaigns.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Häzirlikçe açyk aksiýa ýok', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                                errorBuilder: (c, e, s) => Container(height: 160, color: const Color(0xFFE5E7EB)),
                              ),
                            )
                          else
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red[600]!, Colors.orange[500]!],
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
                                _buildTypeBadge(c.type),
                                const SizedBox(height: 12),
                                Text(
                                  c.title,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF111827), height: 1.2),
                                ),
                                if (c.subtitle != null && c.subtitle!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(c.subtitle!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                ],
                                const SizedBox(height: 16),
                                
                                // Prize / Discount Details
                                const Text('Näme berilýär:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                                const SizedBox(height: 6),
                                if (c.prizeTitle != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.emoji_events, color: Color(0xFFD97706), size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(c.prizeTitle!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF78350F)))),
                                        if (c.prizeValue != null && double.tryParse(c.prizeValue.toString()) != null && double.parse(c.prizeValue.toString()) > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
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
                                        child: Text('${c.discountPercent}% arzanladyş', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                      if (c.promoCode != null) ...[
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: const Color(0xFFCBD5E1)), borderRadius: BorderRadius.circular(8)),
                                          child: Text(c.promoCode!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                if (c.description != null)
                                  Text(c.description!, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4)),

                                const SizedBox(height: 16),
                                const Divider(color: Color(0xFFF3F4F6)),
                                const SizedBox(height: 12),
                                
                                // Rules Section
                                const Text('Näme ýerine ýetirmeli:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                                const SizedBox(height: 8),
                                if (c.rulesList != null && c.rulesList!.isNotEmpty)
                                  ...c.rulesList!.map((r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(r.text, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                                      ],
                                    ),
                                  ))
                                else if (c.rules != null && c.rules!.isNotEmpty)
                                  Text(c.rules!, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))
                                else
                                  const Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Color(0xFF64748B), size: 16),
                                      SizedBox(width: 8),
                                      Text('Programma agza bolup gatnaşmak ýeterlik.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                    ],
                                  ),

                                const SizedBox(height: 16),
                                
                                // Metadata (Starts/Ends, Posted Date)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 14, color: Color(0xFF3B82F6)),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(_formatCampaignDuration(c), style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.bold))),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text('Bildiriş goýlan güni: $createdStr', style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
                                          label: const Text('Gatnaşdyňyz', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                        )
                                      : ElevatedButton(
                                          onPressed: c.isActive ? () => _openJoinDialog(c) : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFDC2626),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: Text(c.isActive ? 'Gatnaş' : 'Tamamlandy', style: const TextStyle(fontWeight: FontWeight.bold)),
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
  }

  Widget _buildError(String msg) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(msg), const SizedBox(height: 12), OutlinedButton(onPressed: _fetch, child: const Text('Gaýtadan synanyş'))]));
}

class _JoinCampaignFormSheet extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback onSuccess;

  const _JoinCampaignFormSheet({required this.campaign, required this.onSuccess});

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Üstünlikli gatnaşdyňyz!'), backgroundColor: Colors.green));
      Navigator.pop(context);
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ýalňyşlyk: $e'), backgroundColor: const Color(0xFFDC2626)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  const Text('Aksiýa gatnaşmak', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              
              const Text('Adyňyz we familiýaňyz *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(hintText: 'Adyňyz Familiýaňyz', filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                validator: (value) => value!.isEmpty ? 'Adyňyzy ýazyň' : null,
              ),
              const SizedBox(height: 16),
              
              const Text('Telefon belgiňiz *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: '+993 6...', filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                validator: (value) => value!.isEmpty ? 'Telefon belgiňizi ýazyň' : null,
              ),
              const SizedBox(height: 16),
              
              const Text('E-poçta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'mysal@gmail.com', filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 16),
              
              const Text('Goşmaça bellik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(hintText: 'Bellik ýazyň...', filled: true, fillColor: const Color(0xFFF9FAFB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
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
                      : const Text('Gatnaşmak', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
