import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.status,
    this.photoUrl,
  });

  final String name;
  final String status;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 295,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Top AppBar profile yang lebih tinggi untuk ruang foto.
          Container(
            height: 165,
            padding: const EdgeInsets.fromLTRB(28, 24, 24, 0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientTop, AppColors.gradientBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                      return;
                    }
                    context.go(RouteName.home);
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: SvgPicture.asset(
                    AppAssets.iconBack,
                    width: 41,
                    height: 41,
                  ),
                ),
                const SizedBox(width: 14),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 85,
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  padding: _hasPhoto
                      ? EdgeInsets.zero
                      : const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8FD),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .14),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: _hasPhoto
                      ? ClipOval(
                          child: Image.network(
                            photoUrl!.trim(),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _ProfileFallbackIcon(),
                          ),
                        )
                      : const _ProfileFallbackIcon(),
                ),
                const SizedBox(height: 15),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7E7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF4B8B8)),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1,
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

  bool get _hasPhoto {
    final trimmed = photoUrl?.trim();
    return trimmed != null && trimmed.isNotEmpty;
  }
}

class _ProfileFallbackIcon extends StatelessWidget {
  const _ProfileFallbackIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconPerson,
      colorFilter: const ColorFilter.mode(
        AppColors.secondaryBlue,
        BlendMode.srcIn,
      ),
    );
  }
}
