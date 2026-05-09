import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuni_train/const/colors.dart';
import 'package:tuni_train/controller/search_train_controller.dart';
import 'package:tuni_train/data/data.dart';
import 'package:tuni_train/screen/page/search_result_page.dart';

class SearchTrainPage extends StatefulWidget {
  const SearchTrainPage({super.key});
  @override
  State<SearchTrainPage> createState() => _SearchTrainPageState();
}

class _SearchTrainPageState extends State<SearchTrainPage> {
  String? couponCode;
  final TextEditingController _couponCtrl = TextEditingController();
  final SearchTrainController controller = Get.put(SearchTrainController());
  bool showCouponField = false; // El etat mta3 el affichage
  // Stations (à brancher avec ton controller)

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.blue1,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          'Trouver votre trajet',
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 19,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Blue header ──────────────────────────────────────────
          Container(
            color: AppColors.blue1,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. EL HORIZONTAL SCROLL MTA3 EL LIGNES
                // Na77ina el Container el dhyia9 mta3 el dropdown w 7attina SizedBox direct
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.lines.length + 1,
                      itemBuilder: (context, index) {
                        // ─────────────────────────────
                        // T O U S
                        // ─────────────────────────────
                        if (index == 0) {
                          return Obx(() {
                            final isSelected =
                                controller.selectedNetwork.value == 'ALL';

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => controller.changeNetwork('ALL'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white24,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Tous",
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                        }

                        // ─────────────────────────────
                        // L I N E S
                        // ─────────────────────────────
                        final line = controller.lines[index - 1];

                        return Obx(() {
                          final isSelected =
                              controller.selectedNetwork.value == line.id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => controller.changeNetwork(line.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white24,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    line.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ),

                // 2. EL CARD MTA3 EL GARES (Départ/Arrivée)
                Obx(() => _buildStationsCard()),
              ],
            ),
          ),

          // ── Scrollable body ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Date row ─────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionTile(
                          label: 'Aller',
                          value: _fmtDateTime(
                            controller.departureDate.value,
                            controller.departureTime.value,
                          ),
                          icon: Icons.calendar_today_rounded,
                          onTap: () => _pickDateTime(isDeparture: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => controller.hasReturn.value
                              ? _buildOptionTile(
                                  label: 'Retour',
                                  value: _fmtDateTime(
                                    controller.returnDate.value,
                                    controller.returnTime.value,
                                  ),
                                  icon: Icons.calendar_month_rounded,
                                  onTap: () =>
                                      _pickDateTime(isDeparture: false),
                                  onClose: () {
                                    controller.hasReturn.value = false;
                                    controller.returnDate.value = null;
                                    controller.returnTime.value = null;
                                    controller.returnDateTime.value = null;
                                  },
                                )
                              : _buildAddReturnButton(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Passagers ───────────────────────────
                  _buildOptionTile(
                    label: 'Passagers',
                    value: _passengersLabel(),
                    icon: Icons.people_alt_outlined,
                    onTap: _showPassengersSheet,
                  ),

                  const SizedBox(height: 20),

                  // ── Coupon ──────────────────────────────
                  _buildCouponField(),
                ],
              ),
            ),
          ),

          // ── SEARCH BUTTON (تحت النص مباشرة) ──
          // ── Search button ──────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── NOTICE (NOW ABOVE BUTTON) ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 15,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Avant de procéder à l'achat, consultez les changements de trafic ferroviaire prévus.",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── SEARCH BUTTON ──
              _buildSearchButton(),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // STATIONS CARD
  // ────────────────────────────────────────────────────────────────
  Widget _buildStationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStationRow(
            label: 'De',
            hint: controller.from.value.isEmpty
                ? 'Gare de départ'
                : controller.from.value,
            icon: Icons.trip_origin_rounded,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.bluePale),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              _buildStationRow(
                label: 'À',
                hint: controller.to.value.isEmpty
                    ? 'Gare d\'arrivée'
                    : controller.to.value,
                icon: Icons.location_on_rounded,
              ),
              Positioned(
                right: 16,
                child: GestureDetector(
                  onTap: _swapStations,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.blue1,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: AppColors.blue1,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationRow({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => _openStationPicker(isFrom: label == 'De'),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue1, size: 22),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // 🔥 IMPORTANT FIX HERE
                Obx(() {
                  final text = (label == 'De')
                      ? (controller.from.value.isEmpty
                            ? 'Gare de départ'
                            : controller.from.value)
                      : (controller.to.value.isEmpty
                            ? 'Gare d\'arrivée'
                            : controller.to.value);

                  return Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // OPTION TILE
  // ────────────────────────────────────────────────────────────────
  Widget _buildOptionTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onClose,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: Colors.black54),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onClose != null)
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.black45,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // ADD RETURN BUTTON
  // ────────────────────────────────────────────────────────────────
  Widget _buildAddReturnButton() {
    return GestureDetector(
      onTap: () => controller.hasReturn.value = true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.blue2, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              size: 17,
              color: AppColors.blue2,
            ),
            const SizedBox(width: 6),
            Text(
              'Ajouter retour',
              style: GoogleFonts.poppins(
                color: AppColors.blue2,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // COUPON FIELD
  // ────────────────────────────────────────────────────────────────
  Widget _buildCouponField() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      // Transition mte3 el dhouhour tji smooth
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: !showCouponField
          ? // ── Bouton "Plus" (Ma7tout fih InkWell bech tnajjem tenzel 3lih) ──
            InkWell(
              key: const ValueKey('buttonPlus'),
              onTap: () => setState(() => showCouponField = true),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.blue1,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Vous avez un code promo ?',
                      style: GoogleFonts.poppins(
                        fontSize: 16, // Kabbarna fel ktiba bech traha bel bahi
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue1,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : // ── El Champ mta3 el Coupon m3a bouton "Annuler" ──
            Column(
              key: const ValueKey('couponField'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _couponCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.local_offer_outlined,
                        color: AppColors.blue1,
                        size: 22,
                      ),
                      hintText: 'Entrez votre code',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                      // ── Bouton VALIDER (Design Pro) ──
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue1,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(
                              () => couponCode = _couponCtrl.text.trim(),
                            );
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            'Valider',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                // ── Bouton pour masquer le champ (Fermer) ──
                TextButton.icon(
                  onPressed: () => setState(() {
                    showCouponField = false;
                    _couponCtrl.clear(); // Ikhtiari: tfassa5 el ktiba ki tsakar
                  }),
                  icon: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  label: Text(
                    'Annuler',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // SEARCH BUTTON
  // ────────────────────────────────────────────────────────────────
  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      color: AppColors.bgPage,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue1,
          foregroundColor: AppColors.white,
          elevation: 4,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () async {
          debugPrint("════════════════════════════");
          debugPrint("SEARCH BUTTON CLICKED");

          // CHECK DATE
          if (controller.departureDateTime.value == null) {
            debugPrint("❌ departureDateTime is NULL");

            Get.snackbar("Erreur", "Sélectionnez la date et l'heure de départ");
            return;
          }

          debugPrint(
            "✅ Departure DateTime: ${controller.departureDateTime.value}",
          );

          // SET TIME
          controller.selectedTime.value = TimeOfDay(
            hour: controller.departureDateTime.value!.hour,
            minute: controller.departureDateTime.value!.minute,
          );

          debugPrint(
            "✅ Selected Time: "
            "${controller.selectedTime.value!.hour}:"
            "${controller.selectedTime.value!.minute}",
          );

          debugPrint("FROM: ${controller.from.value}");
          debugPrint("TO: ${controller.to.value}");

          debugPrint("Adults: ${controller.adults.value}");
          debugPrint("Children: ${controller.children.value}");
          debugPrint("Babies: ${controller.babies.value}");

          debugPrint("Coupon: $couponCode");

          // SEARCH
          await controller.searchTrains();

          debugPrint("🚆 Trains Found: ${controller.nextTrains.length}");

          // NAVIGATION
          if (controller.nextTrains.isNotEmpty) {
            debugPrint("✅ NAVIGATING TO RESULT PAGE");

            final args = {
              "from": controller.from.value,
              "to": controller.to.value,
              "date": controller.departureDateTime.value,
              "adults": controller.adults.value,
              "children": controller.children.value,
              "babies": controller.babies.value,
              "coupon": couponCode,
            };

            debugPrint("════════ ARGUMENTS ════════");
            debugPrint(args.toString());
            debugPrint("═══════════════════════════");

            Get.to(() => const SearchResultPage(), arguments: args);
          } else {
            debugPrint("❌ NO TRAINS FOUND");
          }
        },
        child: Text(
          'Rechercher des trains',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: .4,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // DATE + TIME PICKER  (bottom sheet)
  // ────────────────────────────────────────────────────────────────
  Future<void> _pickDateTime({required bool isDeparture}) async {
    DateTime tempDate = isDeparture
        ? (controller.departureDate.value ?? DateTime.now())
        : (controller.returnDate.value ?? DateTime.now());

    TimeOfDay tempTime = isDeparture
        ? (controller.departureTime.value ?? TimeOfDay.now())
        : (controller.returnTime.value ?? TimeOfDay.now());

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 16,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HANDLE
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    isDeparture
                        ? 'Date et heure de départ'
                        : 'Date et heure de retour',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blue1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DATE PICKER
                  Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.blue1,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: tempDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      onDateChanged: (d) => setS(() => tempDate = d),
                    ),
                  ),

                  const Divider(),
                  const SizedBox(height: 8),

                  // TIME PICKER
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.blue1,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Heure :',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),

                      GestureDetector(
                        onTap: () async {
                          final t = await showTimePicker(
                            context: ctx,
                            initialTime: tempTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.blue1,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (t != null) {
                            setS(() => tempTime = t);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bluePale,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tempTime.format(ctx),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.blue1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // CONFIRM BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final DateTime finalDateTime = DateTime(
                          tempDate.year,
                          tempDate.month,
                          tempDate.day,
                          tempTime.hour,
                          tempTime.minute,
                        );

                        setState(() {
                          if (isDeparture) {
                            // ✅ DEPART
                            controller.departureDate.value = tempDate;
                            controller.departureTime.value = tempTime;
                            controller.departureDateTime.value = finalDateTime;

                            controller.selectedTime.value = tempTime;
                          } else {
                            // ✅ RETURN
                            controller.returnDate.value = tempDate;
                            controller.returnTime.value = tempTime;
                            controller.returnDateTime.value = finalDateTime;
                          }
                        });

                        Navigator.pop(sheetCtx);
                      },
                      child: Text(
                        'Confirmer',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
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

  // ────────────────────────────────────────────────────────────────
  // PASSENGERS BOTTOM SHEET
  // ────────────────────────────────────────────────────────────────
  void _showPassengersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (outerCtx) => Material(
        color: Colors.transparent,
        child: StatefulBuilder(
          builder: (ctx, setS) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HANDLE
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.blue1,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Passagers',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blue1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _passengerRow(
                    ctx: ctx,
                    setS: setS,
                    label: 'Adultes',
                    sublabel: '',
                    count: controller.adults.value,
                    minVal: 1,
                    onDec: () {
                      setS(() => controller.adults.value--);
                      setState(() {});
                    },
                    onInc: () {
                      setS(() => controller.adults.value++);
                      setState(() {});
                    },
                  ),

                  const Divider(),

                  _passengerRow(
                    ctx: ctx,
                    setS: setS,
                    label: 'Enfants',
                    sublabel: '(0-5 ans gratuit)',
                    count: controller.children.value,
                    minVal: 0,
                    onDec: () {
                      setS(() => controller.children.value--);
                      setState(() {});
                    },
                    onInc: () {
                      setS(() => controller.children.value++);
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(outerCtx),
                      child: Text(
                        'Confirmer',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _passengerRow({
    required BuildContext ctx,
    required StateSetter setS,
    required String label,
    required String sublabel,
    required int count,
    required int minVal,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              if (sublabel.isNotEmpty)
                Text(
                  sublabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
            ],
          ),
          const Spacer(),
          _counterBtn(Icons.remove, count <= minVal ? null : onDec),
          SizedBox(
            width: 34,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.blue1,
              ),
            ),
          ),
          _counterBtn(Icons.add, onInc),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade100 : AppColors.bluePale,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? Colors.grey : AppColors.blue1,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // STATION PICKER  (à brancher avec ton controller)
  // ────────────────────────────────────────────────────────────────
  void _openStationPicker({required bool isFrom}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            final isAll = controller.selectedNetwork.value == 'ALL';
            final line = controller.getSelectedLine();

            // ✅ FIX 1: keep filtered OUTSIDE rebuild logic
            List<String> allStations = isAll
                ? controller.stations.map((e) => e.name).toList()
                : controller.filteredStations.map((e) => e.name).toList();

            // local reactive list
            ValueNotifier<List<String>> filtered = ValueNotifier<List<String>>(
              allStations,
            );

            void filter(String query) {
              filtered.value = allStations
                  .where((s) => s.toLowerCase().contains(query.toLowerCase()))
                  .toList();
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (ctx, scroll) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.bgPage,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // HANDLE
                      Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // TITLE CARD (clean header style)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.train, color: AppColors.blue1),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Obx(() {
                                  final isAll =
                                      controller.selectedNetwork.value == 'ALL';
                                  final line = controller.getSelectedLine();

                                  return Text(
                                    isAll
                                        ? "Toutes les stations"
                                        : "Stations de ${line?.name ?? ''}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // SEARCH FIELD (modern style like your app)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Rechercher une station...',
                              hintStyle: GoogleFonts.poppins(fontSize: 13),
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            onChanged: filter,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // LIST
                      Expanded(
                        child: ValueListenableBuilder<List<String>>(
                          valueListenable: filtered,
                          builder: (_, list, __) {
                            return ListView.separated(
                              controller: scroll,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (_, i) {
                                final station = list[i];

                                return Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: AppColors.blue1,
                                    ),
                                    title: Text(
                                      station,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onTap: () {
                                      controller.selectStation(isFrom, station);
                                      controller.update();
                                      Navigator.pop(ctx);
                                    },
                                  ),
                                );
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
      },
    );
  }

  // ────────────────────────────────────────────────────────────────
  // SWAP STATIONS
  // ────────────────────────────────────────────────────────────────
  void _swapStations() {
    controller.swapStations();
    setState(() {});
  }

  // ────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────
  String _fmtDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return 'Sélectionner';
    final d =
        '${date.day.toString().padLeft(2, '0')} ${DaysData.months[date.month - 1]}';
    final t = time != null
        ? ' · ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : '';
    return '$d$t';
  }

  String _passengersLabel() {
    final parts = <String>[];
    if (controller.adults.value > 0)
      parts.add(
        '${controller.adults.value} Adulte${controller.adults.value > 1 ? 's' : ''}',
      );
    if (controller.children.value > 0)
      parts.add(
        '${controller.children.value} Enfant${controller.children.value > 1 ? 's' : ''}',
      );
    return parts.isEmpty ? '1 Adulte' : parts.join(' · ');
  }
}
