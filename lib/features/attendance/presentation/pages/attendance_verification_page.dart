import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/router/route_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../data/datasources/attendance_remote_data_source.dart';
import '../../data/models/attendance_submit_response.dart';
import '../../data/models/attendance_work_config.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../history/presentation/providers/attendance_history_provider.dart';
import '../models/attendance_flow_type.dart';
import '../utils/attendance_availability.dart';
import '../widgets/attendance_flow_app_bar.dart';
import '../widgets/attendance_primary_button.dart';

class CheckInVerificationPage extends StatefulWidget {
  const CheckInVerificationPage({super.key, required this.flowType});

  final AttendanceFlowType flowType;

  @override
  State<CheckInVerificationPage> createState() =>
      _CheckInVerificationPageState();
}

class _CheckInVerificationPageState extends State<CheckInVerificationPage>
    with WidgetsBindingObserver {
  final AttendanceRepository _attendanceRepository = AttendanceRepository(
    AttendanceRemoteDataSource(ApiClient.dio),
  );

  CameraController? _cameraController;
  File? _capturedPhoto;
  File? _resizedPhoto;
  String? _uploadedImageUrl;
  AttendanceSubmitResponse? _attendanceResponse;
  double? _actualLatitude;
  double? _actualLongitude;
  bool _isInitializingCamera = true;
  bool _isTakingPicture = false;
  bool _isPreparingVerification = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVerificationFlow();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _initializeVerificationFlow();
    }
  }

  Future<void> _initializeVerificationFlow() async {
    if (_isTakingPicture || _isPreparingVerification) return;

    _isPreparingVerification = true;
    try {
      setState(() {
        _isInitializingCamera = true;
        _cameraError = null;
      });

      final availability = await _resolveAttendanceAvailability();
      if (!mounted) return;

      if (!_isAttendanceAvailable(availability)) {
        setState(() => _isInitializingCamera = false);
        return;
      }

      final isAllowedTime = await _ensureWithinAllowedAttendanceTime();
      if (!mounted) return;

      if (!isAllowedTime) {
        setState(() => _isInitializingCamera = false);
        return;
      }

      final hasCurrentLocation = await _prepareCurrentLocation();
      if (!mounted) return;

      if (!hasCurrentLocation) {
        setState(() => _isInitializingCamera = false);
        return;
      }

      await _initializeFrontCamera();
    } finally {
      _isPreparingVerification = false;
    }
  }

  Future<bool> _ensureWithinAllowedAttendanceTime() async {
    AttendanceWorkConfig workConfig;

    try {
      workConfig = await _attendanceRepository.getWorkConfig();
    } on AttendanceWorkConfigException catch (error) {
      if (!mounted) return false;
      _showCameraBlockingError(error.message);
      return false;
    }

    final now = DateTime.now();
    if (widget.flowType.isCheckIn &&
        now.isBefore(workConfig.minimumClockInDateTime(now))) {
      if (!mounted) return false;
      _showCameraBlockingError(
        'Presensi masuk hanya dapat dilakukan mulai pukul '
        '${workConfig.minimumClockInLabel}',
      );
      return false;
    }

    if (!widget.flowType.isCheckIn &&
        now.isBefore(workConfig.minimumClockOutDateTime(now))) {
      if (!mounted) return false;
      _showCameraBlockingError(
        'Presensi keluar hanya dapat dilakukan mulai pukul '
        '${workConfig.minimumClockOutLabel}',
      );
      return false;
    }

    return true;
  }

  void _showCameraBlockingError(String message) {
    setState(() => _cameraError = message);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _initializeFrontCamera() async {
    final activeController = _cameraController;
    if (activeController != null && activeController.value.isInitialized) {
      setState(() => _isInitializingCamera = false);
      return;
    }

    setState(() {
      _isInitializingCamera = true;
      _cameraError = null;
    });

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (!mounted) return;
      setState(() {
        _isInitializingCamera = false;
        _cameraError = permission.isPermanentlyDenied
            ? 'Izin kamera ditolak permanen. Aktifkan kamera dari pengaturan aplikasi.'
            : 'Izin kamera diperlukan untuk verifikasi presensi.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      CameraDescription? frontCamera;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (frontCamera == null) {
        throw CameraException(
          'front_camera_unavailable',
          'Kamera depan tidak tersedia.',
        );
      }

      await _disposeCamera();
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isInitializingCamera = false;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _isInitializingCamera = false;
        _cameraError = error.description ?? 'Kamera tidak dapat digunakan.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializingCamera = false;
        _cameraError = 'Kamera tidak dapat digunakan.';
      });
    }
  }

  Future<void> _disposeCamera() async {
    final controller = _cameraController;
    _cameraController = null;
    await controller?.dispose();
  }

  void _resetCaptureState() {
    setState(() {
      _capturedPhoto = null;
      _resizedPhoto = null;
      _uploadedImageUrl = null;
      _attendanceResponse = null;
      _isTakingPicture = false;
    });
  }

  Future<void> _capturePhotoAndContinue() async {
    final controller = _cameraController;
    if (_isTakingPicture) return;

    if (controller == null || !controller.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera belum siap. Coba lagi.')),
      );
      return;
    }

    try {
      setState(() => _isTakingPicture = true);

      final photo = await controller.takePicture();
      final capturedPhoto = File(photo.path);
      if (!mounted) return;
      setState(() => _capturedPhoto = capturedPhoto);

      // Tampilkan preview secepat mungkin sebelum proses resize/GPS/upload berjalan.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      final resizedPhoto = await _resizeAttendancePhoto(capturedPhoto);
      final resizedPhotoSize = await resizedPhoto.length();
      final hasFreshLocation = await _prepareCurrentLocation();
      if (!hasFreshLocation ||
          _actualLatitude == null ||
          _actualLongitude == null) {
        if (!mounted) return;
        _resetCaptureState();
        return;
      }

      final availability = await _resolveAttendanceAvailability();
      if (!mounted) return;
      if (!_isAttendanceAvailable(availability)) {
        _resetCaptureState();
        return;
      }

      final attendanceLatitude = _actualLatitude!;
      final attendanceLongitude = _actualLongitude!;

      final uploadedImageUrl = await _attendanceRepository.uploadImage(
        resizedPhoto,
      );
      _logAttendanceLocation(
        latitude: attendanceLatitude,
        longitude: attendanceLongitude,
      );
      final submitAvailability = await _resolveAttendanceAvailability();
      if (!mounted) return;
      if (!_isAttendanceAvailable(submitAvailability)) {
        _resetCaptureState();
        return;
      }

      final attendanceResponse = widget.flowType.isCheckIn
          ? await _attendanceRepository.checkIn(
              selfieUrl: uploadedImageUrl,
              latitude: attendanceLatitude,
              longitude: attendanceLongitude,
              lateReason: '',
            )
          : await _submitCheckOut(
              uploadedImageUrl,
              latitude: attendanceLatitude,
              longitude: attendanceLongitude,
            );

      if (!mounted) return;
      setState(() {
        _resizedPhoto = resizedPhoto;
        _uploadedImageUrl = uploadedImageUrl;
        _attendanceResponse = attendanceResponse;
        _isTakingPicture = false;
      });

      // Response presensi disimpan sementara untuk kebutuhan UI/data step berikutnya.
      debugPrint('Attendance response received, preparing success flow.');
      debugPrint('Captured attendance photo: ${_capturedPhoto!.path}');
      debugPrint(
        'Resized attendance photo: ${_resizedPhoto!.path} '
        '($resizedPhotoSize bytes)',
      );
      debugPrint('Uploaded attendance image URL: $_uploadedImageUrl');
      debugPrint('Attendance response data: ${_attendanceResponse!.data}');
      try {
        ProviderScope.containerOf(
          context,
          listen: false,
        ).invalidate(attendanceHistoriesProvider);
        debugPrint('Attendance history refresh invalidated.');
      } catch (error, stackTrace) {
        debugPrint('Attendance history refresh invalidate failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      final loadingRoute = widget.flowType.isCheckIn
          ? RouteName.checkInLoading
          : RouteName.checkOutLoading;
      debugPrint(
        'Attendance navigation to loading start: '
        'route=$loadingRoute, extra=${attendanceResponse.data}',
      );
      try {
        context.push(loadingRoute, extra: attendanceResponse);
        debugPrint('Attendance navigation to loading dispatched.');
      } catch (error, stackTrace) {
        debugPrint('Attendance navigation to loading failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        rethrow;
      }
    } on CameraException catch (error) {
      if (!mounted) return;
      _resetCaptureState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.description ?? 'Gagal mengambil foto.')),
      );
    } on AttendanceUploadException catch (error) {
      if (!mounted) return;
      _resetCaptureState();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } on AttendanceSubmitException catch (error) {
      if (!mounted) return;
      _resetCaptureState();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('Attendance verification unexpected error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _resetCaptureState();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengambil foto.')));
    }
  }

  Future<AttendanceAvailability?> _resolveAttendanceAvailability() async {
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      return await container.read(attendanceAvailabilityProvider.future);
    } catch (error, stackTrace) {
      debugPrint('Attendance availability resolve failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  bool _isAttendanceAvailable(AttendanceAvailability? availability) {
    if (availability == null) {
      _showCameraBlockingError('Data presensi belum dapat dimuat.');
      return false;
    }

    final unavailableReason = widget.flowType.isCheckIn
        ? availability.checkInUnavailableReason
        : availability.checkOutUnavailableReason;
    if (unavailableReason == null) return true;

    _showCameraBlockingError(unavailableReason.message);
    return false;
  }

  void _logAttendanceLocation({
    required double latitude,
    required double longitude,
  }) {
    debugPrint(
      'Attendance request location (${DateTime.now().toIso8601String()}): '
      'latitude=$latitude, longitude=$longitude',
    );
  }

  Future<bool> _prepareCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      _showLocationError(
        'Layanan lokasi/GPS belum aktif. Aktifkan lokasi untuk melanjutkan presensi.',
      );
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return false;
      _showLocationError('Izin lokasi diperlukan untuk verifikasi presensi.');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      _showLocationError(
        'Izin lokasi ditolak permanen. Aktifkan izin lokasi dari pengaturan aplikasi.',
      );
      return false;
    }

    try {
      final position = await _getFreshCurrentPosition();

      if (!mounted) return false;
      // TODO(Backend):
      // Koordinat aktual ini dikirim ke request presensi dan akan divalidasi backend.
      setState(() {
        _actualLatitude = position.latitude;
        _actualLongitude = position.longitude;
      });
      return true;
    } catch (_) {
      if (!mounted) return false;
      _showLocationError(
        'Lokasi gagal didapatkan. Pastikan GPS aktif lalu coba lagi.',
      );
      return false;
    }
  }

  Future<Position> _getFreshCurrentPosition() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
      timeLimit: Duration(seconds: 15),
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).first.timeout(const Duration(seconds: 15));
  }

  void _showLocationError(String message) {
    setState(() => _cameraError = message);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<AttendanceSubmitResponse> _submitCheckOut(
    String selfieUrl, {
    required double latitude,
    required double longitude,
  }) async {
    final overtime = await _resolveOvertimeConfirmation();

    return _attendanceRepository.checkOut(
      selfieUrl: selfieUrl,
      latitude: latitude,
      longitude: longitude,
      overtime: overtime,
    );
  }

  Future<bool> _resolveOvertimeConfirmation() async {
    AttendanceWorkConfig workConfig;

    try {
      workConfig = await _attendanceRepository.getWorkConfig();
    } on AttendanceWorkConfigException catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return false;
    }

    final now = DateTime.now();
    final clockOutTime = workConfig.clockOutDateTime(now);
    if (now.isBefore(clockOutTime)) return false;
    if (!mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _OvertimeConfirmationDialog(),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar halaman verifikasi
            AttendanceFlowAppBar(
              title: 'Presensi',
              subtitle: widget.flowType.verificationSubtitle,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 24, 28),
                children: [
                  // Preview kamera depan
                  Container(
                    height: 355,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101318),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _CameraPreviewArea(
                            controller: _cameraController,
                            capturedPhoto: _capturedPhoto,
                            isInitializing: _isInitializingCamera,
                            isProcessing: _isTakingPicture,
                            errorMessage: _cameraError,
                            onRetry: _initializeVerificationFlow,
                          ),
                        ),
                        const _CameraCorner(alignment: Alignment.topLeft),
                        const _CameraCorner(alignment: Alignment.topRight),
                        const _CameraCorner(alignment: Alignment.bottomLeft),
                        const _CameraCorner(alignment: Alignment.bottomRight),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Card Tips Verifikasi
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 18, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8FD),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFC6E6F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.iconTips,
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF4C9CB2),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips Verifikasi',
                                style: TextStyle(
                                  color: Color(0xFF4C9CB2),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Pastikan pencahayaan cukup, lepas masker atau kacamata hitam, posisikan wajah dengan benar, dan aktifkan GPS',
                                style: TextStyle(
                                  color: Color(0xFF6A7B83),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.37,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tombol mulai verifikasi
                  AttendancePrimaryButton(
                    label: _isTakingPicture
                        ? 'Mengambil Foto...'
                        : 'Mulai Verifikasi',
                    onPressed: _capturePhotoAndContinue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}

Future<File> _resizeAttendancePhoto(File sourceFile) async {
  final sourceBytes = await sourceFile.readAsBytes();
  final resizedBytes = await compute(_resizeAttendancePhotoBytes, sourceBytes);
  final resizedFile = File(_resizedPhotoPath(sourceFile.path));

  await resizedFile.writeAsBytes(resizedBytes, flush: true);
  return resizedFile;
}

Uint8List _resizeAttendancePhotoBytes(Uint8List sourceBytes) {
  const targetMaxBytes = 1024 * 1024;
  const qualitySteps = [85, 75, 65, 55, 45];
  const maxDimensions = [1280, 1080, 900, 720, 640];

  final decoded = img.decodeImage(sourceBytes);
  if (decoded == null) {
    throw const FormatException('Format foto tidak dapat diproses.');
  }

  final orientedImage = img.bakeOrientation(decoded);
  Uint8List bestBytes = Uint8List.fromList(
    img.encodeJpg(orientedImage, quality: 85),
  );

  for (final maxDimension in maxDimensions) {
    final resizedImage = _resizeKeepingAspectRatio(orientedImage, maxDimension);

    for (final quality in qualitySteps) {
      final encoded = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: quality),
      );
      bestBytes = encoded;

      if (encoded.lengthInBytes < targetMaxBytes) {
        return encoded;
      }
    }
  }

  return bestBytes;
}

img.Image _resizeKeepingAspectRatio(img.Image source, int maxDimension) {
  final width = source.width;
  final height = source.height;

  if (width <= maxDimension && height <= maxDimension) {
    return source;
  }

  if (width >= height) {
    return img.copyResize(source, width: maxDimension);
  }

  return img.copyResize(source, height: maxDimension);
}

String _resizedPhotoPath(String sourcePath) {
  final extensionIndex = sourcePath.lastIndexOf('.');
  if (extensionIndex == -1) return '${sourcePath}_resized.jpg';
  return '${sourcePath.substring(0, extensionIndex)}_resized.jpg';
}

class _OvertimeConfirmationDialog extends StatelessWidget {
  const _OvertimeConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Apakah Anda sedang lembur?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _OvertimeDialogButton(
                    label: 'Tidak',
                    isPrimary: false,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OvertimeDialogButton(
                    label: 'Ya',
                    isPrimary: true,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OvertimeDialogButton extends StatelessWidget {
  const _OvertimeDialogButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 51,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColors.primaryRed
              : const Color(0xFFFFE7E7),
          foregroundColor: isPrimary ? Colors.white : AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: isPrimary ? AppColors.primaryRed : const Color(0xFFF0B8B8),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _CameraPreviewArea extends StatelessWidget {
  const _CameraPreviewArea({
    required this.controller,
    required this.capturedPhoto,
    required this.isInitializing,
    required this.isProcessing,
    required this.errorMessage,
    required this.onRetry,
  });

  final CameraController? controller;
  final File? capturedPhoto;
  final bool isInitializing;
  final bool isProcessing;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final activeController = controller;
    final previewPhoto = capturedPhoto;

    if (previewPhoto != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Preview hasil capture dibuat mirror agar konsisten dengan live kamera depan.
            Transform.flip(
              flipX: true,
              child: Image.file(previewPhoto, fit: BoxFit.cover),
            ),
            if (isProcessing)
              const Align(
                alignment: Alignment.bottomCenter,
                child: _CaptureSuccessFeedback(),
              ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return _CameraMessage(
        message: errorMessage!,
        actionLabel: 'Coba Lagi',
        onActionPressed: onRetry,
      );
    }

    if (isInitializing ||
        activeController == null ||
        !activeController.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: activeController.value.previewSize?.height ?? 280,
          height: activeController.value.previewSize?.width ?? 280,
          child: CameraPreview(activeController),
        ),
      ),
    );
  }
}

class _CaptureSuccessFeedback extends StatelessWidget {
  const _CaptureSuccessFeedback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '✓ Foto berhasil diambil',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Memproses verifikasi...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE8EEF2),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onActionPressed,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CameraCorner extends StatelessWidget {
  const _CameraCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(42),
        child: SizedBox(
          width: 20,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: isLeft
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
                right: isLeft
                    ? BorderSide.none
                    : const BorderSide(color: Colors.white, width: 2),
                top: isTop
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
                bottom: isTop
                    ? BorderSide.none
                    : const BorderSide(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
