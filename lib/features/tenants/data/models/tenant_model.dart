import '../../domain/entities/tenant_entity.dart';

/// TenantModel handles SQLite serialization and deserialization for tenants.
class TenantModel extends TenantEntity {
  const TenantModel({
    required super.id,
    required super.fullName,
    super.nationalId,
    required super.phone,
    super.alternatePhone,
    super.email,
    super.address,
    super.notes,
    super.isArchived,
    required super.createdAt,
  });

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      nationalId: map['national_id'] as String?,
      phone: map['phone'] as String,
      alternatePhone: map['alternate_phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      isArchived: (map['is_archived'] as int?) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'national_id': nationalId,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'email': email,
      'address': address,
      'notes': notes,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory TenantModel.fromEntity(TenantEntity entity) {
    return TenantModel(
      id: entity.id,
      fullName: entity.fullName,
      nationalId: entity.nationalId,
      phone: entity.phone,
      alternatePhone: entity.alternatePhone,
      email: entity.email,
      address: entity.address,
      notes: entity.notes,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
    );
  }
}
