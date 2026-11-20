import '../../domain/entities/unit_entity.dart';

/// UnitModel handles SQLite serialization and deserialization for units.
class UnitModel extends UnitEntity {
  const UnitModel({
    required super.id,
    required super.propertyId,
    required super.unitNumber,
    super.floorNumber,
    required super.type,
    super.status,
    required super.rentAmount,
    super.depositAmount,
    super.electricityMeter,
    super.waterMeter,
    super.specificationsJson,
    super.notes,
    required super.createdAt,
  });

  factory UnitModel.fromMap(Map<String, dynamic> map) {
    return UnitModel(
      id: map['id'].toString(),
      propertyId: map['property_id'].toString(),
      unitNumber: map['unit_number'].toString(),
      floorNumber: (map['floor_number'] as num?)?.toInt() ?? 0,
      type: map['type'].toString(),
      status: map['status']?.toString() ?? 'vacant',
      rentAmount: (map['rent_amount'] as num?)?.toInt() ?? 0,
      depositAmount: (map['deposit_amount'] as num?)?.toInt() ?? 0,
      electricityMeter: map['electricity_meter']?.toString(),
      waterMeter: map['water_meter']?.toString(),
      specificationsJson: map['specifications_json']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: map['created_at'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'unit_number': unitNumber,
      'floor_number': floorNumber,
      'type': type,
      'status': status,
      'rent_amount': rentAmount,
      'deposit_amount': depositAmount,
      'electricity_meter': electricityMeter,
      'water_meter': waterMeter,
      'specifications_json': specificationsJson,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory UnitModel.fromEntity(UnitEntity entity) {
    return UnitModel(
      id: entity.id,
      propertyId: entity.propertyId,
      unitNumber: entity.unitNumber,
      floorNumber: entity.floorNumber,
      type: entity.type,
      status: entity.status,
      rentAmount: entity.rentAmount,
      depositAmount: entity.depositAmount,
      electricityMeter: entity.electricityMeter,
      waterMeter: entity.waterMeter,
      specificationsJson: entity.specificationsJson,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
