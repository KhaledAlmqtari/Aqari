import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// DatabaseService is responsible for managing the local SQLite database.
///
/// It encapsulates:
/// - Cross-platform initialization (Android, iOS, Windows, Desktop).
/// - Enforcing relational integrity via foreign keys (`PRAGMA foreign_keys = ON`).
/// - Table creation and indexes for fast searching and constraint checking.
/// - Providing atomic transactions for compound financial operations.
class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'real_estate_local.db';
  static const int _databaseVersion = 1;

  /// Returns the singleton database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database depending on the running platform.
  Future<Database> _initDatabase() async {
    // If running on Desktop (Windows, Linux, macOS), use sqflite_common_ffi
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        // Enforce Foreign Key constraints for relational data integrity
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onOpen: (db) async {
        // Ensure tenant_id column exists on existing databases
        try {
          await db.execute('ALTER TABLE expenses ADD COLUMN tenant_id TEXT;');
        } catch (_) {}
      },
      onCreate: _onCreate,
    );
  }

  /// Creates all core application tables, indexes, and initial constraints.
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // 1. Properties Table
    batch.execute('''
      CREATE TABLE properties (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        address TEXT,
        city TEXT,
        notes TEXT,
        total_units INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      );
    ''');
    batch.execute(
        'CREATE INDEX idx_properties_archived ON properties (is_archived);');

    // 2. Units Table
    batch.execute('''
      CREATE TABLE units (
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        unit_number TEXT NOT NULL,
        floor_number INTEGER DEFAULT 0,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        rent_amount INTEGER NOT NULL,
        deposit_amount INTEGER DEFAULT 0,
        electricity_meter TEXT,
        water_meter TEXT,
        specifications_json TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE RESTRICT
      );
    ''');
    batch.execute('CREATE INDEX idx_units_property ON units (property_id);');
    batch.execute('CREATE INDEX idx_units_status ON units (status);');

    // 3. Tenants Table
    batch.execute('''
      CREATE TABLE tenants (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        national_id TEXT,
        phone TEXT NOT NULL,
        alternate_phone TEXT,
        email TEXT,
        address TEXT,
        notes TEXT,
        is_archived INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      );
    ''');
    batch.execute('CREATE INDEX idx_tenants_phone ON tenants (phone);');
    batch
        .execute('CREATE INDEX idx_tenants_archived ON tenants (is_archived);');

    // 4. Contracts Table
    batch.execute('''
      CREATE TABLE contracts (
        id TEXT PRIMARY KEY,
        contract_number TEXT UNIQUE NOT NULL,
        unit_id TEXT NOT NULL,
        property_id TEXT NOT NULL,
        tenant_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        payment_cycle TEXT NOT NULL,
        due_day INTEGER DEFAULT 1,
        rent_amount INTEGER NOT NULL,
        deposit_amount INTEGER DEFAULT 0,
        is_rent_separate INTEGER DEFAULT 1,
        status TEXT NOT NULL,
        terms TEXT,
        previous_contract_id TEXT,
        terminated_at TEXT,
        termination_reason TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (unit_id) REFERENCES units (id) ON DELETE RESTRICT,
        FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE RESTRICT,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE RESTRICT
      );
    ''');
    batch.execute('CREATE INDEX idx_contracts_unit ON contracts (unit_id);');
    batch
        .execute('CREATE INDEX idx_contracts_tenant ON contracts (tenant_id);');
    batch.execute('CREATE INDEX idx_contracts_status ON contracts (status);');

    // 5. Services Table (General or Property Specific)
    batch.execute('''
      CREATE TABLE services (
        id TEXT PRIMARY KEY,
        property_id TEXT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        default_fee INTEGER NOT NULL,
        cycle TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
      );
    ''');

    // 6. Contract Services Table
    batch.execute('''
      CREATE TABLE contract_services (
        id TEXT PRIMARY KEY,
        contract_id TEXT NOT NULL,
        service_id TEXT,
        name TEXT NOT NULL,
        amount INTEGER NOT NULL,
        cycle TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (contract_id) REFERENCES contracts (id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE SET NULL
      );
    ''');
    batch.execute(
        'CREATE INDEX idx_contract_services_contract ON contract_services (contract_id);');

    // 7. Invoices Table
    batch.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        invoice_number TEXT UNIQUE NOT NULL,
        contract_id TEXT NOT NULL,
        tenant_id TEXT NOT NULL,
        unit_id TEXT NOT NULL,
        property_id TEXT NOT NULL,
        period_start TEXT NOT NULL,
        period_end TEXT NOT NULL,
        issue_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        total_amount INTEGER NOT NULL,
        paid_amount INTEGER DEFAULT 0,
        remaining_amount INTEGER NOT NULL,
        status TEXT NOT NULL,
        items_json TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (contract_id) REFERENCES contracts (id) ON DELETE RESTRICT,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE RESTRICT,
        FOREIGN KEY (unit_id) REFERENCES units (id) ON DELETE RESTRICT,
        FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE RESTRICT
      );
    ''');
    batch.execute(
        'CREATE INDEX idx_invoices_contract ON invoices (contract_id);');
    batch.execute('CREATE INDEX idx_invoices_status ON invoices (status);');
    batch.execute('CREATE INDEX idx_invoices_due_date ON invoices (due_date);');

    // 8. Invoice Items Table (Snapshot of calculated charges)
    batch.execute('''
      CREATE TABLE invoice_items (
        id TEXT PRIMARY KEY,
        invoice_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
      );
    ''');
    batch.execute(
        'CREATE INDEX idx_invoice_items_invoice ON invoice_items (invoice_id);');

    // 9. Payments Table
    batch.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        receipt_number TEXT UNIQUE NOT NULL,
        invoice_id TEXT NOT NULL,
        tenant_id TEXT NOT NULL,
        contract_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        payment_date TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        reference_number TEXT,
        notes TEXT,
        is_reversed INTEGER DEFAULT 0,
        reverse_reason TEXT,
        reversed_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE RESTRICT,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE RESTRICT,
        FOREIGN KEY (contract_id) REFERENCES contracts (id) ON DELETE RESTRICT
      );
    ''');
    batch
        .execute('CREATE INDEX idx_payments_invoice ON payments (invoice_id);');
    batch.execute('CREATE INDEX idx_payments_date ON payments (payment_date);');

    // 10. Expenses Table
    batch.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        property_id TEXT,
        tenant_id TEXT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount INTEGER NOT NULL,
        expense_date TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE SET NULL,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE SET NULL
      );
    ''');
    batch.execute(
        'CREATE INDEX idx_expenses_property ON expenses (property_id);');
    batch.execute('CREATE INDEX idx_expenses_tenant ON expenses (tenant_id);');
    batch.execute('CREATE INDEX idx_expenses_date ON expenses (expense_date);');

    // 11. Security Deposits Table
    batch.execute('''
      CREATE TABLE deposits (
        id TEXT PRIMARY KEY,
        contract_id TEXT NOT NULL,
        tenant_id TEXT NOT NULL,
        unit_id TEXT NOT NULL,
        amount INTEGER NOT NULL,
        status TEXT NOT NULL,
        received_date TEXT NOT NULL,
        settled_date TEXT,
        refunded_amount INTEGER DEFAULT 0,
        deducted_amount INTEGER DEFAULT 0,
        deduction_reason TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (contract_id) REFERENCES contracts (id) ON DELETE RESTRICT,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id) ON DELETE RESTRICT,
        FOREIGN KEY (unit_id) REFERENCES units (id) ON DELETE RESTRICT
      );
    ''');

    // 12. Application Settings Table (Key-Value)
    batch.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');

    // Insert Default System Settings (YER currency default, etc.)
    batch.execute(
        "INSERT OR REPLACE INTO app_settings (key, value) VALUES ('currency', 'YER');");
    batch.execute(
        "INSERT OR REPLACE INTO app_settings (key, value) VALUES ('company_name', 'إدارة الأملاك العقارية');");

    await batch.commit(noResult: true);
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
