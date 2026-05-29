# Phase 2: Enterprise PostgreSQL Database Design for E‑Procurement ERP

## 1. Design Goals and Enterprise Standards

This database design provides the canonical PostgreSQL data model for an enterprise E‑Procurement ERP covering user access, vendors, sourcing, procurement, inventory, warehousing, invoicing, contracts, approval workflow, audit logging, and notifications.

Enterprise standards applied:

- PostgreSQL 15+ compatible DDL using `pgcrypto` for UUID generation.
- Dedicated application schema: `eproc`.
- UUID primary keys for distributed service compatibility.
- Consistent audit columns: `created_at`, `created_by`, `updated_at`, `updated_by`, `version`, `is_active`.
- Monetary values use `numeric(19,4)`.
- Quantities use `numeric(19,4)`.
- Reference codes use constrained `varchar` columns and unique indexes.
- Soft deactivation through `is_active`, with immutable audit/event records.
- Optimistic locking through `version`.
- Foreign keys enforce transactional integrity inside the procurement data boundary.
- Targeted indexes support workflow queues, document lookups, joins, and reporting.

## 2. ER Diagram Description

### 2.1 Core Entity Groups

```text
User Management / Role Management
---------------------------------
users ──< user_roles >── roles ──< role_permissions >── permissions
users ──< approval_tasks
users ──< audit_logs
users ──< notifications

Vendor / Contract Management
----------------------------
vendors ──< vendor_contacts
vendors ──< vendor_bank_accounts
vendors ──< contracts ──< contract_lines
vendors ──< rfq_vendor_invites
vendors ──< purchase_orders
vendors ──< invoices

Purchase Requisition / RFQ / PO / Invoice
-----------------------------------------
purchase_requisitions ──< purchase_requisition_lines
purchase_requisitions ──< rfqs ──< rfq_lines
rfqs ──< rfq_vendor_invites ──< rfq_responses ──< rfq_response_lines
purchase_requisitions ──< purchase_orders ──< purchase_order_lines
purchase_orders ──< goods_receipts ──< goods_receipt_lines
purchase_orders ──< invoices ──< invoice_lines
contracts ──< purchase_orders

Inventory / Warehouse
---------------------
warehouses ──< warehouse_locations
items ──< inventory_balances
warehouse_locations ──< inventory_balances
items ──< inventory_transactions
warehouses ──< inventory_transactions
purchase_order_lines ──< goods_receipt_lines ──< inventory_transactions

Approval Workflow / Audit / Notification
----------------------------------------
approval_workflows ──< approval_steps ──< approval_tasks
approval_workflows may apply to PR, RFQ, PO, invoice, contract, vendor objects
all major business objects ──< audit_logs through entity_type/entity_id
users ──< notifications
```

### 2.2 Relationship Summary

- A user can have many roles; a role can contain many permissions.
- A vendor can have many contacts, bank accounts, contracts, RFQ invitations, purchase orders, and invoices.
- A purchase requisition can have many lines and can result in one or more RFQs and/or purchase orders.
- An RFQ has many RFQ lines, invited vendors, responses, and response lines.
- A purchase order belongs to a vendor and may reference a requisition and/or contract.
- A purchase order has many lines; receiving and invoice lines reference PO lines for 2-way/3-way matching.
- Inventory balances are maintained per item, warehouse, and warehouse location.
- Approval workflows are reusable definitions; approval tasks are runtime approvals assigned to users.
- Audit logs are immutable append-only records linked by `entity_type` and `entity_id`.

## 3. Table Catalog

| Module | Tables |
| --- | --- |
| User Management | `users`, `user_sessions` |
| Role Management | `roles`, `permissions`, `user_roles`, `role_permissions` |
| Vendor Management | `vendors`, `vendor_contacts`, `vendor_bank_accounts` |
| Purchase Requisition | `purchase_requisitions`, `purchase_requisition_lines` |
| RFQ | `rfqs`, `rfq_lines`, `rfq_vendor_invites`, `rfq_responses`, `rfq_response_lines` |
| Purchase Order | `purchase_orders`, `purchase_order_lines`, `goods_receipts`, `goods_receipt_lines` |
| Invoice | `invoices`, `invoice_lines` |
| Inventory | `item_categories`, `items`, `inventory_balances`, `inventory_transactions` |
| Warehouse | `warehouses`, `warehouse_locations` |
| Approval Workflow | `approval_workflows`, `approval_steps`, `approval_tasks` |
| Audit Logs | `audit_logs` |
| Notification | `notifications` |
| Contract Management | `contracts`, `contract_lines` |

## 4. Table Details

### 4.1 User and Role Management

#### `users`

| Column | Type | Constraints / Description |
| --- | --- | --- |
| `user_id` | `uuid` | PK, default `gen_random_uuid()` |
| `employee_no` | `varchar(50)` | Unique employee identifier |
| `username` | `varchar(100)` | Unique login name |
| `email` | `varchar(255)` | Unique email |
| `password_hash` | `varchar(255)` | Password hash for local auth or migration fallback |
| `first_name` | `varchar(100)` | Given name |
| `last_name` | `varchar(100)` | Family name |
| `department` | `varchar(100)` | Department/cost center grouping |
| `status` | `varchar(30)` | `ACTIVE`, `LOCKED`, `DISABLED` |
| `last_login_at` | `timestamptz` | Last successful login |
| standard columns | mixed | `created_at`, `created_by`, `updated_at`, `updated_by`, `version`, `is_active` |

Indexes: unique `username`, unique `email`, unique `employee_no`, index `status`.

#### `roles`, `permissions`, `user_roles`, `role_permissions`

- `roles` defines enterprise roles such as requester, buyer, approver, AP analyst, warehouse manager, and administrator.
- `permissions` defines atomic access rights such as `PR_CREATE`, `PO_APPROVE`, and `INVOICE_MATCH`.
- `user_roles` and `role_permissions` are many-to-many bridge tables with composite primary keys.

### 4.2 Vendor Management

#### `vendors`

| Column | Type | Constraints / Description |
| --- | --- | --- |
| `vendor_id` | `uuid` | PK |
| `vendor_code` | `varchar(50)` | Unique enterprise vendor code |
| `legal_name` | `varchar(255)` | Registered legal name |
| `tax_identifier` | `varchar(100)` | Tax/VAT/GST identifier |
| `vendor_type` | `varchar(50)` | `MANUFACTURER`, `DISTRIBUTOR`, `SERVICE_PROVIDER` |
| `status` | `varchar(30)` | `DRAFT`, `APPROVED`, `BLOCKED`, `INACTIVE` |
| `risk_rating` | `varchar(30)` | `LOW`, `MEDIUM`, `HIGH`, `CRITICAL` |
| `payment_terms` | `varchar(50)` | e.g. `NET30` |
| `currency_code` | `char(3)` | ISO currency |
| address columns | mixed | registered address |
| standard columns | mixed | audit/locking columns |

Relationships: vendor has many contacts, bank accounts, contracts, RFQ invites, POs, and invoices.

### 4.3 Procurement Transaction Tables

#### Purchase Requisitions

- `purchase_requisitions` stores PR headers, requester, status, budget, and approval state.
- `purchase_requisition_lines` stores requested goods/services, quantities, prices, accounting dimensions, and required dates.

#### RFQ

- `rfqs` stores sourcing event header data.
- `rfq_lines` can be sourced from PR lines.
- `rfq_vendor_invites` tracks invited vendors and response status.
- `rfq_responses` stores supplier submissions.
- `rfq_response_lines` stores supplier pricing and lead-time responses per RFQ line.

#### Purchase Orders and Receiving

- `purchase_orders` stores PO header data and supplier commitment terms.
- `purchase_order_lines` stores ordered item/service lines.
- `goods_receipts` records receipt headers.
- `goods_receipt_lines` records accepted/rejected receipt quantities against PO lines.

#### Invoices

- `invoices` stores supplier invoice headers, matching status, and approval status.
- `invoice_lines` links to PO lines where applicable and supports tax and matching calculations.

### 4.4 Inventory and Warehouse

- `item_categories` supports category hierarchy.
- `items` stores material/service master records.
- `warehouses` stores physical/logical warehouses.
- `warehouse_locations` stores bins/zones/locations.
- `inventory_balances` stores on-hand, reserved, and available quantities by item/location.
- `inventory_transactions` stores immutable inventory movements.

### 4.5 Approval Workflow, Audit, and Notification

- `approval_workflows` defines approval process templates by entity type.
- `approval_steps` defines step sequence, approver role, thresholds, and escalation rules.
- `approval_tasks` stores runtime approval assignments and decisions.
- `audit_logs` stores immutable entity changes and security-relevant activity.
- `notifications` stores in-app, email, SMS, and webhook notifications.

### 4.6 Contract Management

- `contracts` stores contract headers, vendor, dates, value, status, owner, and legal metadata.
- `contract_lines` stores item/category scoped pricing, committed quantities, and release limits.

## 5. Primary Keys and Foreign Keys

The SQL create script defines all primary keys and foreign keys. Core examples:

- `users.user_id` is referenced by requester, buyer, approver, owner, creator, updater, notification, and audit fields.
- `vendors.vendor_id` is referenced by vendor contacts, bank accounts, contracts, RFQs, purchase orders, and invoices.
- `purchase_requisitions.pr_id` is referenced by PR lines, RFQs, and purchase orders.
- `purchase_orders.po_id` is referenced by PO lines, goods receipts, and invoices.
- `purchase_order_lines.po_line_id` is referenced by receipt lines and invoice lines.
- `items.item_id` is referenced by PR lines, RFQ lines, PO lines, contract lines, inventory balances, and inventory transactions.
- `approval_workflows.workflow_id` is referenced by approval steps and approval tasks.

## 6. Index Strategy

### 6.1 Unique Indexes

- Business document numbers: PR, RFQ, PO, GRN, invoice, contract.
- Enterprise codes: user username/email/employee number, role code, permission code, vendor code, item SKU, warehouse code.

### 6.2 Operational Indexes

- Status and date indexes for work queues: PR, RFQ, PO, invoice, approval tasks.
- Foreign-key indexes for joins and referential operations.
- Partial index for unread notifications.
- JSONB GIN index on `audit_logs.changed_fields`.

### 6.3 Reporting Indexes

- Vendor/date indexes on PO and invoice headers.
- Item/warehouse/location indexes on inventory balances and transactions.
- Category and active status indexes on item master.

## 7. Sample Records

The SQL script includes sample seed records for:

- Administrative and procurement users.
- Roles and permissions.
- Vendor master data, contact, and bank account.
- Item categories and items.
- Warehouse and warehouse location.
- Purchase requisition and PR line.
- RFQ, RFQ line, vendor invite, vendor response, and response line.
- Contract and contract line.
- Purchase order and PO line.
- Goods receipt and receipt line.
- Inventory balance and transaction.
- Invoice and invoice line.
- Approval workflow, approval step, and approval task.
- Notification and audit log.

## 8. SQL Create Scripts

The executable PostgreSQL DDL and seed data are maintained in:

- [`database/eprocurement_schema.sql`](../../database/eprocurement_schema.sql)
