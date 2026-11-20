import '../../domain/entities/property_entity.dart';

/// PropertyModel is the Data Layer representation of a Property,
/// providing serialization and deserialization for SQLite records.
class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.name,
    required super.type,
    super.address,
    super.city,
    super.notes,
    super.totalUnits,
    super.isArchived,
    required super.createdAt,
  });

  /// Factory constructor to deserialize a SQLite row map into [PropertyModel]
  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'].toString(),
      name: map['name'].toString(),
      type: map['type'].toString(),
      address: map['address']?.toString(),
      city: map['city']?.toString(),
      notes: map['notes']?.toString(),
      totalUnits: (map['total_units'] as num?)?.toInt() ?? 0,
      isArchived: (map['is_archived'] as num?)?.toInt() == 1,
      createdAt: map['created_at'].toString(),
    );
  }

  /// Converts [PropertyModel] into a SQLite row map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'city': city,
      'notes': notes,
      'total_units': totalUnits,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt,
    };
  }

  /// Factory to convert Domain [PropertyEntity] into Data [PropertyModel]
  factory PropertyModel.fromEntity(PropertyEntity entity) {
    return PropertyModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      address: entity.address,
      city: entity.city,
      notes: entity.notes,
      totalUnits: entity.totalUnits,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
    );
  }
}
