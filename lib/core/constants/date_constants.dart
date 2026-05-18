/// Shared French date abbreviations used across tickets, QR screens, and panels.
/// Index 0 is intentionally empty so month/day numbers map directly
/// (e.g. kFrMonths[1] == 'Jan', kFrDays[1] == 'Lun').
library;

/// French month abbreviations. Index 0 is unused.
const List<String> kFrMonths = [
  '',
  'Jan',
  'Fév',
  'Mar',
  'Avr',
  'Mai',
  'Jun',
  'Jul',
  'Aoû',
  'Sep',
  'Oct',
  'Nov',
  'Déc',
];

/// French day abbreviations (Monday = 1 … Sunday = 7). Index 0 is unused.
const List<String> kFrDays = [
  '',
  'Lun',
  'Mar',
  'Mer',
  'Jeu',
  'Ven',
  'Sam',
  'Dim',
];

/// Month abbreviations without a leading empty slot (for 0-based month pickers).
const List<String> kFrMonths0 = [
  'Jan',
  'Fév',
  'Mar',
  'Avr',
  'Mai',
  'Jun',
  'Jul',
  'Aoû',
  'Sep',
  'Oct',
  'Nov',
  'Déc',
];

/// Format a [DateTime] as "Lun. 5 Jan" using French abbreviations.
String formatFrDate(DateTime d) =>
    '${kFrDays[d.weekday]}. ${d.day} ${kFrMonths[d.month]}';

/// Format a [DateTime] as "Jan 2025".
String formatFrMonthYear(DateTime d) => '${kFrMonths[d.month]} ${d.year}';

/// Format a [DateTime] as "Lun 5 Jan 2025" (no dot, with year).
String formatFrDateFull(DateTime d) =>
    '${kFrDays[d.weekday]} ${d.day} ${kFrMonths[d.month]} ${d.year}';
