import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AttendanceInfoTile extends StatelessWidget {
  const AttendanceInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueAlign = TextAlign.left,
  });

  final String icon;
  final String label;
  final String value;
  final TextAlign valueAlign;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F7FC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            icon,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              Color(0xFF4C9CB2),
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: valueAlign == TextAlign.right
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8A8F98),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                textAlign: valueAlign,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
