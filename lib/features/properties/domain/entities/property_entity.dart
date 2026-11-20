/// PropertyEntity represents a real estate asset managed by the owner.
///
/// Domain layer entity - independent of Flutter frameworks and SQLite data models.
class PropertyEntity {
  /// Unique identifier (UUID)
  final String id;

  /// Property name (e.g. "برج النور", "عمارة الأمل")
  final String name;

  /// Property type: 'residential', 'commercial', 'mixed'
  final String type;

  /// Physical street address
  final String? address;

  /// City or district
  final String? city;

  /// Additional administrative notes
  final String? notes;

  /// Total count of units configured within this property
  final int totalUnits;

  /// Whether this property has been archived
  final bool isArchived;

  /// Creation timestamp (ISO string)
  final String createdAt;

  const PropertyEntity({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.city,
    this.notes,
    this.totalUnits = 0,
    this.isArchived = false,
    required this.createdAt,
  });

  /// Creates a copy with modified values
  PropertyEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    String? city,
    String? notes,
    int? totalUnits,
    bool? isArchived,
    String? createdAt,
  }) {
    return PropertyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      totalUnits: totalUnits ?? this.totalUnits,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
