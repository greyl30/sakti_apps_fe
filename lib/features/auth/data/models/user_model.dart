import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

// Model data user dari backend
@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.namaLengkap,
    required this.email,
    this.nomorTelepon,
    this.fotoUrl,
    this.peran,
    this.levelJabatan,
    this.atasanLangsungId,
    this.divisi,
    this.unit,
    this.statusKaryawan,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  final String id;

  @JsonKey(name: 'nama_lengkap')
  final String namaLengkap;

  final String email;

  @JsonKey(name: 'nomor_telepon')
  final String? nomorTelepon;

  @JsonKey(name: 'foto_url')
  final String? fotoUrl;

  final String? peran;

  @JsonKey(name: 'level_jabatan')
  final String? levelJabatan;

  @JsonKey(name: 'atasan_langsung_id')
  final String? atasanLangsungId;

  final String? divisi;
  final String? unit;

  @JsonKey(name: 'status_karyawan')
  final String? statusKaryawan;

  @JsonKey(name: 'dibuat_pada')
  final String? dibuatPada;

  @JsonKey(name: 'diperbarui_pada')
  final String? diperbaruiPada;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
