/// TenantEntity represents a lessee/tenant renting units across properties.
class TenantEntity {
  final String id;
  final String fullName;
  final String? nationalId;
  final String phone;
  final String? alternatePhone;
  final String? email;
  final String? address;
  final String? notes;
  final bool isArchived;
  final String createdAt;

  const TenantEntity({
    required this.id,
    required this.fullName,
    this.nationalId,
    required this.phone,
    this.alternatePhone,
    this.email,
    this.address,
    this.notes,
    this.isArchived = false,
    required this.createdAt,
  });

  TenantEntity copyWith({
    String? id,
    String? fullName,
    String? nationalId,
    String? phone,
    String? alternatePhone,
    String? email,
    String? address,
    String? notes,
    bool? isArchived,
    String? createdAt,
  }) {
    return TenantEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
