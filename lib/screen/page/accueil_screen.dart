import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/data/stations_data.dart';


class AccueilPageScreen extends StatefulWidget {
  const AccueilPageScreen({super.key});

  @override
  State<AccueilPageScreen> createState() => _AccueilPageScreenState();
}

class _AccueilPageScreenState extends State<AccueilPageScreen> {
  String _selectedNetwork = 'ALL';

  Widget _buildNetworkChip(String value, String label) {
    final isSelected = _selectedNetwork == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNetwork = value;

          List<String> stations;

          switch (value) {
            case 'RFR':
              stations = StationsData.rfr;
              break;
            case 'TUNIS':
              stations = StationsData.banlieueTunis;
              break;
            case 'SAHEL':
              stations = StationsData.banlieueSahel;
              break;
            case 'INTL':
              stations = StationsData.international;
              break;
            default:
              stations = _allStations;
          }

          // ✅ Update FROM & TO automatically
          if (stations.isNotEmpty) {
            _from = stations.first;
            _to = stations.length > 1 ? stations[1] : stations.first;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? AppColors.blue1 : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // All stations combined (deduplicated, sorted)
  static final List<String> _allStations = () {
    final set = <String>{
      ...StationsData.grandesLignes,
      ...StationsData.banlieueTunis,
      ...StationsData.banlieueSahel,
      ...StationsData.rfr,
      ...StationsData.international,
    };
    final list = set.toList()..sort();
    return list;
  }();

  // ── State ─────────────────────────────────────────────────────
  String _from = 'TUNIS';
  String _to = 'SOUSSE';
  DateTime _selectedDate = DateTime.now();

  // ── Actions ───────────────────────────────────────────────────
  void _swapStations() => setState(() {
    final tmp = _from;
    _from = _to;
    _to = tmp;
  });

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.blue1,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showStationPicker(bool isFrom) {
    final controller = TextEditingController();

    // ✅ Use ONLY selected network from main screen
    List<String> getFilteredStations() {
      switch (_selectedNetwork) {
        case 'RFR':
          return StationsData.rfr;
        case 'TUNIS':
          return StationsData.banlieueTunis;
        case 'SAHEL':
          return StationsData.banlieueSahel;
        case 'INTL':
          return StationsData.international;
        default:
          return _allStations;
      }
    }

    List<String> filtered = getFilteredStations();

    void applySearch(String query) {
      final source = getFilteredStations();

      filtered = source
          .where((s) => s.toLowerCase().contains(query.toLowerCase().trim()))
          .toList();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              builder: (_, scrollCtrl) => Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0C8E8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isFrom ? 'Ville de départ' : 'Ville d\'arrivée',
                          style: GoogleFonts.poppins(
                            color: AppColors.blue1,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔍 SEARCH ONLY
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.blue1,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Rechercher une gare...',
                              prefixIcon: Icon(Icons.search_rounded),
                              border: InputBorder.none,
                            ),
                            onChanged: (q) {
                              setModal(() {
                                applySearch(q);
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ✅ Show active network
                        Text(
                          'Réseau: $_selectedNetwork',
                          style: GoogleFonts.poppins(
                            color: AppColors.blue3,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollCtrl,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final station = filtered[i];

                        final isSelected = isFrom
                            ? station == _from
                            : station == _to;

                        return ListTile(
                          title: Text(station),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.blue1,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              if (isFrom) {
                                _from = station;
                              } else {
                                _to = station;
                              }
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'EEEE, d MMMM yyyy',
      'fr_FR',
    ).format(DateTime.now());
    final selectedDateStr = DateFormat(
      'd MMMM yyyy',
      'fr_FR',
    ).format(_selectedDate);
    final isToday =
        _selectedDate.day == DateTime.now().day &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.year == DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(dateStr),
              const SizedBox(height: 20),
              _buildSearchCard(selectedDateStr, isToday),
              const SizedBox(height: 24),
              _buildSectionTitle('Prochain départ'),
              const SizedBox(height: 10),
              _buildNextTrain(),
              const SizedBox(height: 24),
              _buildSectionTitle('Destinations populaires'),
              const SizedBox(height: 10),
              // _buildDestinationsGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('Services à bord'),
              const SizedBox(height: 10),
              _buildServices(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader(String dateStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: GoogleFonts.poppins(color: AppColors.blue3, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Bonjour, Hadil 👋',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => {},
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.blue1,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'H',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search card ───────────────────────────────────────────────
  Widget _buildSearchCard(String selectedDateStr, bool isToday) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Réserver un billet',
            style: GoogleFonts.poppins(
              color: AppColors.blueLight,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 10),

          // 🚀 FILTER NETWORK (NEW)
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildNetworkChip('ALL', 'Toutes'),
                _buildNetworkChip('RFR', 'RFR'),
                _buildNetworkChip('TUNIS', 'Tunis'),
                _buildNetworkChip('SAHEL', 'Sahel'),
                _buildNetworkChip('INTL', 'Intl'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // De / Swap / À
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showStationPicker(true),
                  child: _buildStationBox('De', _from),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _swapStations,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showStationPicker(false),
                  child: _buildStationBox('À', _to),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Date
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isToday
                        ? 'Aujourd\'hui, $selectedDateStr'
                        : selectedDateStr,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Search button
          GestureDetector(
            onTap: () {
              /*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultatsTrainsPage(
                    from: _from,
                    to: _to,
                    date: _selectedDate,
                  ),
                ),
              );*/
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.blue2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rechercher un train',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.blueLight,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Next train ────────────────────────────────────────────────
  Widget _buildNextTrain() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB0C8E8), width: 0.5),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '08:30',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Tunis',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '2h 15min',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Expanded(
                      child: Divider(color: Color(0xFFB0C8E8), thickness: 0.5),
                    ),
                    Icon(Icons.train_rounded, color: AppColors.blue2, size: 16),
                    Expanded(
                      child: Divider(color: Color(0xFFB0C8E8), thickness: 0.5),
                    ),
                  ],
                ),
                Text(
                  'Direct',
                  style: GoogleFonts.poppins(
                    color: AppColors.blue3,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '10:45',
                style: GoogleFonts.poppins(
                  color: AppColors.blue1,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Sfax',
                style: GoogleFonts.poppins(
                  color: AppColors.blue3,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bluePale,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '7.5 DT',
              style: GoogleFonts.poppins(
                color: AppColors.blue1,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Destinations grid ─────────────────────────────────────────
  /* _buildDestinationsGrid() {
    final List<Destination> destinations = [
      Destination(
        name: "Mosquée Zitouna",
        location: "Tunis · Médina",
        image: "lib/assets/zitouna.jpg",
        color: AppColors.blue,
        videoPath: "lib/assets/zitouna.mp4",
        date: "Fondée vers 737 ap. J.-C.",
        classification: "Mosquée historique · Patrimoine UNESCO",
        history:
            "La mosquée Zitouna est la plus ancienne mosquée de Tunis. Elle a été un centre religieux et universitaire majeur pendant des siècles.",
        importance:
            "Centre de science islamique et symbole de l’identité de Tunis",
        description:
            "Mosquée Zitouna est un monument islamique historique majeur en Tunisie.",
      ),
      Destination(
        name: "Amphithéâtre d'El Jem",
        location: "Mahdia · El Jem",
        image: "lib/assets/eljem.jpg",
        color: AppColors.orange,
        videoPath: "lib/assets/eljm.mp4",
        date: "Construit vers 238 ap. J.-C.",
        classification: "Amphithéâtre romain · UNESCO",
        history:
            "Un des plus grands amphithéâtres romains utilisés pour les combats de gladiateurs.",
        importance: "Capacité 35 000 spectateurs · très bien conservé",
        description: "Monument romain impressionnant classé UNESCO.",
      ),
      Destination(
        name: "Sidi Bou Saïd",
        location: "Tunis · Village bleu",
        image: "lib/assets/sidibousaid.jpg",
        color: AppColors.lightBlue,
        videoPath: "lib/assets/sidibousaid.mp4",
        date: "Développé à partir du XIIIe siècle",
        classification: "Village historique · site culturel",
        history:
            "Construit autour du mausolée du saint Sidi Bou Saïd. Connu pour ses maisons blanches et bleues.",
        importance: "Destination touristique et artistique mondiale",
        description: "Village célèbre pour son architecture bleue et blanche.",
      ),
      Destination(
        name: "Dougga",
        location: "Béja · UNESCO",
        image: "lib/assets/dougga.jpg",
        color: AppColors.green,
        videoPath: "lib/assets/dougga.mp4",
        date: "VIe siècle av. J.-C.",
        classification: "Site archéologique romain · UNESCO",
        history:
            "Ancienne ville numide puis romaine contenant temples, théâtre et thermes.",
        importance: "Un des sites antiques les mieux conservés du monde",
        description: "Ville antique romaine très bien conservée.",
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: destinations.length,
      itemBuilder: (_, i) => _buildDestinationCard(destinations[i]),
    );
  }*/
  /*
  Widget _buildDestinationCard(Destination d) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB0C8E8), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    d.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: d.color.withOpacity(0.15),
                      child: Center(
                        child: Icon(
                          Icons.landscape_rounded,
                          color: d.color,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                // 👁 ICON ON IMAGE
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => ExplorePage(destination: d));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  style: GoogleFonts.poppins(
                    color: _blue1,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  d.location,
                  style: GoogleFonts.poppins(color: _blue3, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }*/

  // ── Services ──────────────────────────────────────────────────
  Widget _buildServices() {
    final services = [
      _Service(Icons.coffee_rounded, 'Café'),
      _Service(Icons.wifi_rounded, 'Wi-Fi'),
      _Service(Icons.airline_seat_recline_normal_rounded, 'Confort'),
      _Service(Icons.usb_rounded, 'USB'),
    ];
    return Row(
      children: services
          .map(
            (s) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: s == services.last ? 0 : 10),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFB0C8E8),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.bluePale,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(s.icon, color: AppColors.blue1, size: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.blue1,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.blue1,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Service {
  final IconData icon;
  final String label;
  const _Service(this.icon, this.label);
}
