import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memex/utils/date_util.dart';
import 'package:memex/utils/user_storage.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final startTime = parseLocalDateTime(data['start_time']);
    final endTime = parseLocalDateTime(data['end_time']);

    final String title = data['title'] ?? 'Event';
    final String? location = data['location'];

    final localeName = UserStorage.l10n.localeName;
    final DateFormat timeFormat = DateFormat('HH:mm', localeName);
    final DateFormat monthFormat = DateFormat('MMM', localeName);
    final DateFormat dayFormat = DateFormat('dd', localeName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xD1FFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xD9FFFFFF),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08111827),
              blurRadius: 18,
            ),
          ],
        ),
        child: Row(
          children: [
            // Date block
            Container(
              width: 47,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF5B6CFF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    startTime != null
                        ? monthFormat.format(startTime).toUpperCase()
                        : '---',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.45,
                      color: const Color(0xFF5B6CFF),
                    ),
                  ),
                  Text(
                    startTime != null ? dayFormat.format(startTime) : '--',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: -0.45,
                      color: const Color(0xFF5B6CFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 23 / 18,
                      letterSpacing: -0.45,
                      color: const Color(0xFF0A0A0A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: SvgPicture.asset(
                          'assets/icons/time_clock.svg',
                          width: 13,
                          height: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        startTime != null
                            ? '${timeFormat.format(startTime)}-${endTime != null ? timeFormat.format(endTime) : '?'}'
                            : 'TBD',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 23 / 14,
                          letterSpacing: -0.45,
                          color: const Color(0xFF99A1AF),
                        ),
                      ),
                    ],
                  ),
                  if (location != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFF99A1AF)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 23 / 14,
                              letterSpacing: -0.45,
                              color: const Color(0xFF99A1AF),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
