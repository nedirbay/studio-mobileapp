import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    
    // Premium High-Contrast Color Palette
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final bodyColor = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151); // Gray-200 in dark, Gray-700 in light
    final dateColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563); // Gray-400 in dark, Gray-600 in light

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: titleColor,
        elevation: 0,
        title: const Text(
          'Gizlinlik syýasaty',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gizlinlik syýasaty we düzgünler',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: titleColor,
                letterSpacing: -0.5,
              ),
            ),
            const Divider(height: 32, thickness: 1),
            _buildParagraph(
              '1. Maglumatlaryň ýygnalmagy',
              'Programma tarapyndan ulanyjylaryň hasap açmak üçin girizen ulanyjy ady, e-poçta salgysy we paroly ýaly maglumatlary ýygnalýar we saklanylýar. Bu maglumatlar ulanyjylara hasaplaryna girmäge we buýruklaryny yzarlaýmaga kömek edýär.',
              titleColor,
              bodyColor,
            ),
            _buildParagraph(
              '2. E-poçta we OTP kodlary',
              'Siziň e-poçtaňyz diňe hasabyňyzy tassyklamak üçin zerur bolan OTP (bir gezeklik tassyklama) kodlaryny ugratmak we buýruklaryňyz baradaky habarlary size ýetirmek üçin ulanylýar. Siziň rugsadyňyz bolmazdan e-poçtaňyz başga taraplara berilmeýär.',
              titleColor,
              bodyColor,
            ),
            _buildParagraph(
              '3. Maglumatlaryň goraglylygy',
              'Biz siziň şahsy maglumatlaryňyzy goramak üçin döwrebap howpsuzlyk tehnologiýalaryny we şifrleme usullaryny ulanýarys. Siziň parollaryňyz we şahsy maglumatlaryňyz gizlin we howpsuz saklanylýar.',
              titleColor,
              bodyColor,
            ),
            _buildParagraph(
              '4. Parol howpsuzlygy',
              'Siziň paroluňyz arka fonda hasaplanan we şifrlenen görnüşde saklanylýar. Hasabyňyzyň howpsuzlygy üçin güýçli parol döretmegiňiz we ony hiç kim bilen paýlaşmazlygyňyz zerurdyr.',
              titleColor,
              bodyColor,
            ),
            _buildParagraph(
              '5. Şertleriň kabul edilmegi',
              'Agza bolmak düwmesine basmazdan ozal bu Gizlinlik syýasatyny okap, kabul etmeli we tanyşandygyňyz barada bellik etmelisiňiz. Syýasatymyzy kabul etmeseňiz agza bolup bilmeýärsiňiz.',
              titleColor,
              bodyColor,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(String title, String body, Color titleColor, Color bodyColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}
