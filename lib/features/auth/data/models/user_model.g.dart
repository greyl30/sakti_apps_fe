// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  namaLengkap: json['nama_lengkap'] as String,
  email: json['email'] as String,
  nomorTelepon: json['nomor_telepon'] as String?,
  fotoUrl: json['foto_url'] as String?,
  peran: json['role'] as String?,
  levelJabatan: json['level_jabatan'] as String?,
  atasanLangsungId: json['atasan_langsung_id'] as String?,
  divisi: json['divisi'] as String?,
  unit: json['unit'] as String?,
  statusKaryawan: json['status_karyawan'] as String?,
  dibuatPada: json['dibuat_pada'] as String?,
  diperbaruiPada: json['diperbarui_pada'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'nama_lengkap': instance.namaLengkap,
  'email': instance.email,
  'nomor_telepon': instance.nomorTelepon,
  'foto_url': instance.fotoUrl,
  'role': instance.peran,
  'level_jabatan': instance.levelJabatan,
  'atasan_langsung_id': instance.atasanLangsungId,
  'divisi': instance.divisi,
  'unit': instance.unit,
  'status_karyawan': instance.statusKaryawan,
  'dibuat_pada': instance.dibuatPada,
  'diperbarui_pada': instance.diperbaruiPada,
};
