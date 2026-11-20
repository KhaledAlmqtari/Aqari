/// UnitEntity represents an individual rentable unit (apartment, shop, office, etc.)
/// within a parent property.
class UnitEntity {
  final String id;
  final String propertyId;
  final String unitNumber;
  final int floorNumber;

  /// Unit type: 'apartment', 'shop', 'office', 'warehouse', 'room', 'villa', 'parking'
  final String type;

  /// Unit status: 'vacant', 'rented', 'maintenance', 'unavailable', 'reserved', 'archived'
  final String status;

  /// Rent amount stored as Integer in base currency units (e.g. 150000 YER)
  final int rentAmount;

  /// Deposit amount stored as Integer
  final int depositAmount;

  final String? electricityMeter;
  final String? waterMeter;
  final String? specificationsJson;
  final String? notes;
  final String createdAt;

  const UnitEntity({
    required this.id,
    required this.propertyId,
    required this.unitNumber,
    this.floorNumber = 0,
    required this.type,
    this.status = 'vacant',
    required this.rentAmount,
    this.depositAmount = 0,
    this.electricityMeter,
    this.waterMeter,
    this.specificationsJson,
    this.notes,
    required this.createdAt,
  });

  /// Helper to check if the unit is available for renting
  bool get isVacant => status.toLowerCase() == 'vacant';

  /// Helper to check if the unit is currently rented
  bool get isRented => status.toLowerCase() == 'rented';

  UnitEntity copyWith({
    String? id,
    String? propertyId,
    String? unitNumber,
    int? floorNumber,
    String? type,
    String? status,
    int? rentAmount,
    int? depositAmount,
    String? electricityMeter,
    String? waterMeter,
    String? specificationsJson,
    String? notes,
    String? createdAt,
  }) {
    return UnitEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      unitNumber: unitNumber ?? this.unitNumber,
      floorNumber: floorNumber ?? this.floorNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      rentAmount: rentAmount ?? this.rentAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      electricityMeter: electricityMeter ?? this.electricityMeter,
      waterMeter: waterMeter ?? this.waterMeter,
      specificationsJson: specificationsJson ?? this.specificationsJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
