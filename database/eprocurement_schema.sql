-- Enterprise E-Procurement ERP PostgreSQL Schema
-- Target: PostgreSQL 15+
-- Schema: eproc

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS eproc;
SET search_path = eproc, public;

-- =============================================================
-- Common domain enums are modeled with CHECK constraints instead
-- of PostgreSQL enum types to simplify enterprise upgrades.
-- =============================================================

-- =============================================================
-- User Management and Role Management
-- =============================================================

CREATE TABLE users (
    user_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_no varchar(50) NOT NULL,
    username varchar(100) NOT NULL,
    email varchar(255) NOT NULL,
    password_hash varchar(255),
    first_name varchar(100) NOT NULL,
    last_name varchar(100) NOT NULL,
    department varchar(100),
    status varchar(30) NOT NULL DEFAULT 'ACTIVE',
    last_login_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_users_employee_no UNIQUE (employee_no),
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT ck_users_status CHECK (status IN ('ACTIVE', 'LOCKED', 'DISABLED')),
    CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE user_sessions (
    session_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    refresh_token_hash varchar(255) NOT NULL,
    issued_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz NOT NULL,
    revoked_at timestamptz,
    ip_address inet,
    user_agent text,
    CONSTRAINT fk_user_sessions_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE roles (
    role_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role_code varchar(80) NOT NULL,
    role_name varchar(150) NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_roles_role_code UNIQUE (role_code),
    CONSTRAINT fk_roles_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_roles_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE permissions (
    permission_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    permission_code varchar(120) NOT NULL,
    permission_name varchar(150) NOT NULL,
    module_name varchar(100) NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_permissions_permission_code UNIQUE (permission_code),
    CONSTRAINT fk_permissions_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_permissions_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    assigned_at timestamptz NOT NULL DEFAULT now(),
    assigned_by uuid,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(role_id),
    CONSTRAINT fk_user_roles_assigned_by FOREIGN KEY (assigned_by) REFERENCES users(user_id)
);

CREATE TABLE role_permissions (
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    granted_at timestamptz NOT NULL DEFAULT now(),
    granted_by uuid,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id) REFERENCES roles(role_id),
    CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES permissions(permission_id),
    CONSTRAINT fk_role_permissions_granted_by FOREIGN KEY (granted_by) REFERENCES users(user_id)
);

-- =============================================================
-- Vendor Management
-- =============================================================

CREATE TABLE vendors (
    vendor_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_code varchar(50) NOT NULL,
    legal_name varchar(255) NOT NULL,
    tax_identifier varchar(100),
    vendor_type varchar(50) NOT NULL,
    status varchar(30) NOT NULL DEFAULT 'DRAFT',
    risk_rating varchar(30) NOT NULL DEFAULT 'LOW',
    payment_terms varchar(50) NOT NULL DEFAULT 'NET30',
    currency_code char(3) NOT NULL DEFAULT 'USD',
    address_line1 varchar(255),
    address_line2 varchar(255),
    city varchar(100),
    state_province varchar(100),
    postal_code varchar(30),
    country_code char(2),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_vendors_vendor_code UNIQUE (vendor_code),
    CONSTRAINT ck_vendors_status CHECK (status IN ('DRAFT', 'APPROVED', 'BLOCKED', 'INACTIVE')),
    CONSTRAINT ck_vendors_risk CHECK (risk_rating IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    CONSTRAINT fk_vendors_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_vendors_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE vendor_contacts (
    vendor_contact_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id uuid NOT NULL,
    contact_name varchar(200) NOT NULL,
    email varchar(255),
    phone varchar(50),
    job_title varchar(100),
    is_primary boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT fk_vendor_contacts_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    CONSTRAINT fk_vendor_contacts_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_vendor_contacts_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE vendor_bank_accounts (
    vendor_bank_account_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    vendor_id uuid NOT NULL,
    bank_name varchar(200) NOT NULL,
    account_name varchar(200) NOT NULL,
    account_number_masked varchar(50) NOT NULL,
    routing_number varchar(50),
    swift_code varchar(20),
    iban_masked varchar(80),
    currency_code char(3) NOT NULL DEFAULT 'USD',
    verification_status varchar(30) NOT NULL DEFAULT 'PENDING',
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT ck_vendor_bank_verification CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED')),
    CONSTRAINT fk_vendor_bank_accounts_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    CONSTRAINT fk_vendor_bank_accounts_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_vendor_bank_accounts_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Inventory and Warehouse Master Data
-- =============================================================

CREATE TABLE item_categories (
    item_category_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_category_id uuid,
    category_code varchar(50) NOT NULL,
    category_name varchar(150) NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_item_categories_code UNIQUE (category_code),
    CONSTRAINT fk_item_categories_parent FOREIGN KEY (parent_category_id) REFERENCES item_categories(item_category_id),
    CONSTRAINT fk_item_categories_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_item_categories_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE items (
    item_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    item_category_id uuid NOT NULL,
    sku varchar(80) NOT NULL,
    item_name varchar(255) NOT NULL,
    item_type varchar(30) NOT NULL DEFAULT 'MATERIAL',
    uom varchar(20) NOT NULL DEFAULT 'EA',
    standard_cost numeric(19,4) NOT NULL DEFAULT 0,
    currency_code char(3) NOT NULL DEFAULT 'USD',
    reorder_point numeric(19,4) NOT NULL DEFAULT 0,
    lead_time_days integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_items_sku UNIQUE (sku),
    CONSTRAINT ck_items_type CHECK (item_type IN ('MATERIAL', 'SERVICE')),
    CONSTRAINT fk_items_category FOREIGN KEY (item_category_id) REFERENCES item_categories(item_category_id),
    CONSTRAINT fk_items_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_items_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE warehouses (
    warehouse_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_code varchar(50) NOT NULL,
    warehouse_name varchar(150) NOT NULL,
    address_line1 varchar(255),
    city varchar(100),
    state_province varchar(100),
    postal_code varchar(30),
    country_code char(2),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_warehouses_code UNIQUE (warehouse_code),
    CONSTRAINT fk_warehouses_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_warehouses_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE warehouse_locations (
    warehouse_location_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    warehouse_id uuid NOT NULL,
    location_code varchar(80) NOT NULL,
    location_name varchar(150),
    location_type varchar(30) NOT NULL DEFAULT 'BIN',
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_warehouse_locations_code UNIQUE (warehouse_id, location_code),
    CONSTRAINT ck_warehouse_locations_type CHECK (location_type IN ('ZONE', 'AISLE', 'RACK', 'BIN', 'RECEIVING', 'QUALITY_HOLD')),
    CONSTRAINT fk_warehouse_locations_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    CONSTRAINT fk_warehouse_locations_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_warehouse_locations_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Contract Management
-- =============================================================

CREATE TABLE contracts (
    contract_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_number varchar(60) NOT NULL,
    vendor_id uuid NOT NULL,
    contract_title varchar(255) NOT NULL,
    contract_type varchar(50) NOT NULL DEFAULT 'MASTER_SERVICE_AGREEMENT',
    status varchar(30) NOT NULL DEFAULT 'DRAFT',
    effective_date date NOT NULL,
    expiration_date date NOT NULL,
    contract_value numeric(19,4) NOT NULL DEFAULT 0,
    currency_code char(3) NOT NULL DEFAULT 'USD',
    owner_user_id uuid NOT NULL,
    auto_renew boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_contracts_number UNIQUE (contract_number),
    CONSTRAINT ck_contracts_status CHECK (status IN ('DRAFT', 'UNDER_REVIEW', 'ACTIVE', 'EXPIRED', 'TERMINATED')),
    CONSTRAINT ck_contract_dates CHECK (expiration_date >= effective_date),
    CONSTRAINT fk_contracts_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    CONSTRAINT fk_contracts_owner FOREIGN KEY (owner_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_contracts_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_contracts_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE contract_lines (
    contract_line_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id uuid NOT NULL,
    item_id uuid,
    line_number integer NOT NULL,
    description text NOT NULL,
    uom varchar(20),
    committed_quantity numeric(19,4),
    unit_price numeric(19,4) NOT NULL,
    release_limit_amount numeric(19,4),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_contract_lines_line UNIQUE (contract_id, line_number),
    CONSTRAINT fk_contract_lines_contract FOREIGN KEY (contract_id) REFERENCES contracts(contract_id),
    CONSTRAINT fk_contract_lines_item FOREIGN KEY (item_id) REFERENCES items(item_id),
    CONSTRAINT fk_contract_lines_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_contract_lines_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Purchase Requisition
-- =============================================================

CREATE TABLE purchase_requisitions (
    pr_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    pr_number varchar(60) NOT NULL,
    requester_user_id uuid NOT NULL,
    department varchar(100),
    cost_center varchar(50),
    status varchar(30) NOT NULL DEFAULT 'DRAFT',
    required_by_date date,
    currency_code char(3) NOT NULL DEFAULT 'USD',
    total_amount numeric(19,4) NOT NULL DEFAULT 0,
    business_justification text,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_purchase_requisitions_number UNIQUE (pr_number),
    CONSTRAINT ck_purchase_requisitions_status CHECK (status IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'CANCELLED', 'CONVERTED')),
    CONSTRAINT fk_pr_requester FOREIGN KEY (requester_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_pr_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_pr_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE purchase_requisition_lines (
    pr_line_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    pr_id uuid NOT NULL,
    line_number integer NOT NULL,
    item_id uuid,
    description text NOT NULL,
    quantity numeric(19,4) NOT NULL,
    uom varchar(20) NOT NULL DEFAULT 'EA',
    estimated_unit_price numeric(19,4) NOT NULL DEFAULT 0,
    estimated_line_amount numeric(19,4) NOT NULL DEFAULT 0,
    gl_account varchar(50),
    cost_center varchar(50),
    required_by_date date,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_pr_lines_line UNIQUE (pr_id, line_number),
    CONSTRAINT ck_pr_lines_quantity CHECK (quantity > 0),
    CONSTRAINT fk_pr_lines_pr FOREIGN KEY (pr_id) REFERENCES purchase_requisitions(pr_id),
    CONSTRAINT fk_pr_lines_item FOREIGN KEY (item_id) REFERENCES items(item_id),
    CONSTRAINT fk_pr_lines_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_pr_lines_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- RFQ
-- =============================================================

CREATE TABLE rfqs (
    rfq_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    rfq_number varchar(60) NOT NULL,
    pr_id uuid,
    rfq_title varchar(255) NOT NULL,
    buyer_user_id uuid NOT NULL,
    status varchar(30) NOT NULL DEFAULT 'DRAFT',
    issue_date date,
    response_due_date timestamptz,
    currency_code char(3) NOT NULL DEFAULT 'USD',
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_rfqs_number UNIQUE (rfq_number),
    CONSTRAINT ck_rfqs_status CHECK (status IN ('DRAFT', 'ISSUED', 'CLOSED', 'AWARDED', 'CANCELLED')),
    CONSTRAINT fk_rfqs_pr FOREIGN KEY (pr_id) REFERENCES purchase_requisitions(pr_id),
    CONSTRAINT fk_rfqs_buyer FOREIGN KEY (buyer_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_rfqs_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_rfqs_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE rfq_lines (
    rfq_line_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    rfq_id uuid NOT NULL,
    pr_line_id uuid,
    line_number integer NOT NULL,
    item_id uuid,
    description text NOT NULL,
    quantity numeric(19,4) NOT NULL,
    uom varchar(20) NOT NULL DEFAULT 'EA',
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_rfq_lines_line UNIQUE (rfq_id, line_number),
    CONSTRAINT fk_rfq_lines_rfq FOREIGN KEY (rfq_id) REFERENCES rfqs(rfq_id),
    CONSTRAINT fk_rfq_lines_pr_line FOREIGN KEY (pr_line_id) REFERENCES purchase_requisition_lines(pr_line_id),
    CONSTRAINT fk_rfq_lines_item FOREIGN KEY (item_id) REFERENCES items(item_id),
    CONSTRAINT fk_rfq_lines_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_rfq_lines_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE rfq_vendor_invites (
    rfq_vendor_invite_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    rfq_id uuid NOT NULL,
    vendor_id uuid NOT NULL,
    invite_status varchar(30) NOT NULL DEFAULT 'INVITED',
    invited_at timestamptz NOT NULL DEFAULT now(),
    responded_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_rfq_vendor_invites UNIQUE (rfq_id, vendor_id),
    CONSTRAINT ck_rfq_vendor_invites_status CHECK (invite_status IN ('INVITED', 'VIEWED', 'RESPONDED', 'DECLINED')),
    CONSTRAINT fk_rfq_vendor_invites_rfq FOREIGN KEY (rfq_id) REFERENCES rfqs(rfq_id),
    CONSTRAINT fk_rfq_vendor_invites_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    CONSTRAINT fk_rfq_vendor_invites_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_rfq_vendor_invites_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE rfq_responses (
    rfq_response_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    rfq_vendor_invite_id uuid NOT NULL,
    vendor_id uuid NOT NULL,
    status varchar(30) NOT NULL DEFAULT 'DRAFT',
    submitted_at timestamptz,
    total_amount numeric(19,4) NOT NULL DEFAULT 0,
    currency_code char(3) NOT NULL DEFAULT 'USD',
    payment_terms varchar(50),
    validity_date date,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT ck_rfq_responses_status CHECK (status IN ('DRAFT', 'SUBMITTED', 'WITHDRAWN', 'AWARDED', 'REJECTED')),
    CONSTRAINT fk_rfq_responses_invite FOREIGN KEY (rfq_vendor_invite_id) REFERENCES rfq_vendor_invites(rfq_vendor_invite_id),
    CONSTRAINT fk_rfq_responses_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    CONSTRAINT fk_rfq_responses_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_rfq_responses_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE rfq_response_lines (
    rfq_response_line_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    rfq_response_id uuid NOT NULL,
    rfq_line_id uuid NOT NULL,
    unit_price numeric(19,4) NOT NULL,
    quantity numeric(19,4) NOT NULL,
    line_amount numeric(19,4) NOT NULL,
    lead_time_days integer,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_rfq_response_lines UNIQUE (rfq_response_id, rfq_line_id),
    CONSTRAINT fk_rfq_response_lines_response FOREIGN KEY (rfq_response_id) REFERENCES rfq_responses(rfq_response_id),
    CONSTRAINT fk_rfq_response_lines_rfq_line FOREIGN KEY (rfq_line_id) REFERENCES rfq_lines(rfq_line_id),
    CONSTRAINT fk_rfq_response_lines_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_rfq_response_lines_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Purchase Order and Receiving
-- =============================================================

CREATE TABLE purchase_orders (
    po_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    po_number varchar(60) NOT NULL,
    vendor_id uuid NOT NULL,
    pr_id uuid,
    contract_id uuid,
    buyer_user_id uuid NOT NULL,
    status varchar(30) NOT NULL DEFAULT 'DRAFT',
    order_date date NOT NULL DEFAULT current_date,
    expected_delivery_date date,
    currency_code char(3) NOT NULL DEFAULT 'USD',
    subtotal_amount numeric(19,4) NOT NULL DEFAULT 0,
    tax_amount numeric(19,4) NOT NULL DEFAULT 0,
    total_amount numeric(19,4) NOT NULL DEFAULT 0,
    ship_to_warehouse_id uuid,
    payment_terms varchar(50),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_purchase_orders_number UNIQUE (po_number),
    CONSTRAINT ck_purchase_orders_status CHECK (status IN ('DRAFT', 'APPROVED', 'ISSUED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'CLOSED', 'CANCELLED')),
    CONSTRAINT fk_po_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    CONSTRAINT fk_po_pr FOREIGN KEY (pr_id) REFERENCES purchase_requisitions(pr_id),
    CONSTRAINT fk_po_contract FOREIGN KEY (contract_id) REFERENCES contracts(contract_id),
    CONSTRAINT fk_po_buyer FOREIGN KEY (buyer_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_po_ship_to_warehouse FOREIGN KEY (ship_to_warehouse_id) REFERENCES warehouses(warehouse_id),
    CONSTRAINT fk_po_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_po_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE purchase_order_lines (
    po_line_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    po_id uuid NOT NULL,
    pr_line_id uuid,
    contract_line_id uuid,
    line_number integer NOT NULL,
    item_id uuid,
    description text NOT NULL,
    quantity numeric(19,4) NOT NULL,
    received_quantity numeric(19,4) NOT NULL DEFAULT 0,
    invoiced_quantity numeric(19,4) NOT NULL DEFAULT 0,
    uom varchar(20) NOT NULL DEFAULT 'EA',
    unit_price numeric(19,4) NOT NULL DEFAULT 0,
    line_amount numeric(19,4) NOT NULL DEFAULT 0,
    tax_amount numeric(19,4) NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_po_lines_line UNIQUE (po_id, line_number),
    CONSTRAINT ck_po_lines_quantity CHECK (quantity > 0),
    CONSTRAINT fk_po_lines_po FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id),
    CONSTRAINT fk_po_lines_pr_line FOREIGN KEY (pr_line_id) REFERENCES purchase_requisition_lines(pr_line_id),
    CONSTRAINT fk_po_lines_contract_line FOREIGN KEY (contract_line_id) REFERENCES contract_lines(contract_line_id),
    CONSTRAINT fk_po_lines_item FOREIGN KEY (item_id) REFERENCES items(item_id),
    CONSTRAINT fk_po_lines_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_po_lines_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE goods_receipts (
    goods_receipt_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    grn_number varchar(60) NOT NULL,
    po_id uuid NOT NULL,
    warehouse_id uuid NOT NULL,
    received_by_user_id uuid NOT NULL,
    receipt_date date NOT NULL DEFAULT current_date,
    status varchar(30) NOT NULL DEFAULT 'POSTED',
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_goods_receipts_number UNIQUE (grn_number),
    CONSTRAINT ck_goods_receipts_status CHECK (status IN ('DRAFT', 'POSTED', 'CANCELLED')),
    CONSTRAINT fk_goods_receipts_po FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id),
    CONSTRAINT fk_goods_receipts_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    CONSTRAINT fk_goods_receipts_received_by FOREIGN KEY (received_by_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_goods_receipts_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_goods_receipts_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE goods_receipt_lines (
    goods_receipt_line_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    goods_receipt_id uuid NOT NULL,
    po_line_id uuid NOT NULL,
    warehouse_location_id uuid,
    received_quantity numeric(19,4) NOT NULL,
    accepted_quantity numeric(19,4) NOT NULL DEFAULT 0,
    rejected_quantity numeric(19,4) NOT NULL DEFAULT 0,
    quality_status varchar(30) NOT NULL DEFAULT 'ACCEPTED',
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT ck_goods_receipt_lines_qty CHECK (received_quantity >= 0 AND accepted_quantity >= 0 AND rejected_quantity >= 0),
    CONSTRAINT ck_goods_receipt_lines_quality CHECK (quality_status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'HOLD')),
    CONSTRAINT fk_gr_lines_gr FOREIGN KEY (goods_receipt_id) REFERENCES goods_receipts(goods_receipt_id),
    CONSTRAINT fk_gr_lines_po_line FOREIGN KEY (po_line_id) REFERENCES purchase_order_lines(po_line_id),
    CONSTRAINT fk_gr_lines_location FOREIGN KEY (warehouse_location_id) REFERENCES warehouse_locations(warehouse_location_id),
    CONSTRAINT fk_gr_lines_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_gr_lines_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Invoice
-- =============================================================

CREATE TABLE invoices (
    invoice_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number varchar(80) NOT NULL,
    vendor_id uuid NOT NULL,
    po_id uuid,
    invoice_date date NOT NULL,
    due_date date,
    status varchar(30) NOT NULL DEFAULT 'RECEIVED',
    match_status varchar(30) NOT NULL DEFAULT 'NOT_MATCHED',
    currency_code char(3) NOT NULL DEFAULT 'USD',
    subtotal_amount numeric(19,4) NOT NULL DEFAULT 0,
    tax_amount numeric(19,4) NOT NULL DEFAULT 0,
    total_amount numeric(19,4) NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_invoices_vendor_number UNIQUE (vendor_id, invoice_number),
    CONSTRAINT ck_invoices_status CHECK (status IN ('RECEIVED', 'VALIDATED', 'APPROVED', 'REJECTED', 'PAID', 'CANCELLED')),
    CONSTRAINT ck_invoices_match_status CHECK (match_status IN ('NOT_MATCHED', 'MATCHED', 'EXCEPTION')),
    CONSTRAINT fk_invoices_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id),
    CONSTRAINT fk_invoices_po FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id),
    CONSTRAINT fk_invoices_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_invoices_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE invoice_lines (
    invoice_line_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id uuid NOT NULL,
    po_line_id uuid,
    line_number integer NOT NULL,
    item_id uuid,
    description text NOT NULL,
    quantity numeric(19,4) NOT NULL,
    uom varchar(20) NOT NULL DEFAULT 'EA',
    unit_price numeric(19,4) NOT NULL DEFAULT 0,
    line_amount numeric(19,4) NOT NULL DEFAULT 0,
    tax_amount numeric(19,4) NOT NULL DEFAULT 0,
    match_variance_amount numeric(19,4) NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_invoice_lines_line UNIQUE (invoice_id, line_number),
    CONSTRAINT fk_invoice_lines_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    CONSTRAINT fk_invoice_lines_po_line FOREIGN KEY (po_line_id) REFERENCES purchase_order_lines(po_line_id),
    CONSTRAINT fk_invoice_lines_item FOREIGN KEY (item_id) REFERENCES items(item_id),
    CONSTRAINT fk_invoice_lines_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_invoice_lines_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Inventory Transactions
-- =============================================================

CREATE TABLE inventory_balances (
    inventory_balance_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id uuid NOT NULL,
    warehouse_id uuid NOT NULL,
    warehouse_location_id uuid NOT NULL,
    on_hand_quantity numeric(19,4) NOT NULL DEFAULT 0,
    reserved_quantity numeric(19,4) NOT NULL DEFAULT 0,
    available_quantity numeric(19,4) NOT NULL DEFAULT 0,
    last_counted_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_inventory_balances UNIQUE (item_id, warehouse_id, warehouse_location_id),
    CONSTRAINT fk_inventory_balances_item FOREIGN KEY (item_id) REFERENCES items(item_id),
    CONSTRAINT fk_inventory_balances_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    CONSTRAINT fk_inventory_balances_location FOREIGN KEY (warehouse_location_id) REFERENCES warehouse_locations(warehouse_location_id),
    CONSTRAINT fk_inventory_balances_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_inventory_balances_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE inventory_transactions (
    inventory_transaction_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id uuid NOT NULL,
    warehouse_id uuid NOT NULL,
    warehouse_location_id uuid,
    transaction_type varchar(30) NOT NULL,
    quantity numeric(19,4) NOT NULL,
    reference_type varchar(50),
    reference_id uuid,
    goods_receipt_line_id uuid,
    transaction_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT ck_inventory_transactions_type CHECK (transaction_type IN ('RECEIPT', 'ISSUE', 'TRANSFER', 'ADJUSTMENT', 'RETURN')),
    CONSTRAINT fk_inventory_transactions_item FOREIGN KEY (item_id) REFERENCES items(item_id),
    CONSTRAINT fk_inventory_transactions_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    CONSTRAINT fk_inventory_transactions_location FOREIGN KEY (warehouse_location_id) REFERENCES warehouse_locations(warehouse_location_id),
    CONSTRAINT fk_inventory_transactions_gr_line FOREIGN KEY (goods_receipt_line_id) REFERENCES goods_receipt_lines(goods_receipt_line_id),
    CONSTRAINT fk_inventory_transactions_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_inventory_transactions_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Approval Workflow
-- =============================================================

CREATE TABLE approval_workflows (
    workflow_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_code varchar(80) NOT NULL,
    workflow_name varchar(150) NOT NULL,
    entity_type varchar(50) NOT NULL,
    min_amount numeric(19,4),
    max_amount numeric(19,4),
    currency_code char(3) DEFAULT 'USD',
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_approval_workflows_code UNIQUE (workflow_code),
    CONSTRAINT ck_approval_workflows_entity CHECK (entity_type IN ('VENDOR', 'PR', 'RFQ', 'PO', 'INVOICE', 'CONTRACT')),
    CONSTRAINT fk_approval_workflows_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_approval_workflows_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE approval_steps (
    approval_step_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id uuid NOT NULL,
    step_sequence integer NOT NULL,
    step_name varchar(150) NOT NULL,
    approver_role_id uuid,
    approver_user_id uuid,
    approval_type varchar(30) NOT NULL DEFAULT 'ANY_ONE',
    escalation_hours integer,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_approval_steps_sequence UNIQUE (workflow_id, step_sequence),
    CONSTRAINT ck_approval_steps_type CHECK (approval_type IN ('ANY_ONE', 'ALL', 'SEQUENTIAL')),
    CONSTRAINT fk_approval_steps_workflow FOREIGN KEY (workflow_id) REFERENCES approval_workflows(workflow_id),
    CONSTRAINT fk_approval_steps_role FOREIGN KEY (approver_role_id) REFERENCES roles(role_id),
    CONSTRAINT fk_approval_steps_user FOREIGN KEY (approver_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_approval_steps_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_approval_steps_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

CREATE TABLE approval_tasks (
    approval_task_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id uuid NOT NULL,
    approval_step_id uuid NOT NULL,
    entity_type varchar(50) NOT NULL,
    entity_id uuid NOT NULL,
    assigned_to_user_id uuid NOT NULL,
    status varchar(30) NOT NULL DEFAULT 'PENDING',
    decision varchar(30),
    comments text,
    assigned_at timestamptz NOT NULL DEFAULT now(),
    decided_at timestamptz,
    due_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT ck_approval_tasks_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'DELEGATED', 'CANCELLED')),
    CONSTRAINT ck_approval_tasks_decision CHECK (decision IS NULL OR decision IN ('APPROVE', 'REJECT', 'DELEGATE')),
    CONSTRAINT fk_approval_tasks_workflow FOREIGN KEY (workflow_id) REFERENCES approval_workflows(workflow_id),
    CONSTRAINT fk_approval_tasks_step FOREIGN KEY (approval_step_id) REFERENCES approval_steps(approval_step_id),
    CONSTRAINT fk_approval_tasks_assignee FOREIGN KEY (assigned_to_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_approval_tasks_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_approval_tasks_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Audit Logs and Notification
-- =============================================================

CREATE TABLE audit_logs (
    audit_log_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type varchar(80) NOT NULL,
    entity_id uuid,
    action varchar(80) NOT NULL,
    actor_user_id uuid,
    changed_fields jsonb,
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    correlation_id uuid,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT fk_audit_logs_actor FOREIGN KEY (actor_user_id) REFERENCES users(user_id)
);

CREATE TABLE notifications (
    notification_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_user_id uuid NOT NULL,
    notification_type varchar(30) NOT NULL DEFAULT 'IN_APP',
    subject varchar(255) NOT NULL,
    message text NOT NULL,
    entity_type varchar(80),
    entity_id uuid,
    delivery_status varchar(30) NOT NULL DEFAULT 'PENDING',
    read_at timestamptz,
    sent_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    created_by uuid,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by uuid,
    version integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    CONSTRAINT ck_notifications_type CHECK (notification_type IN ('IN_APP', 'EMAIL', 'SMS', 'WEBHOOK')),
    CONSTRAINT ck_notifications_status CHECK (delivery_status IN ('PENDING', 'SENT', 'FAILED', 'READ')),
    CONSTRAINT fk_notifications_recipient FOREIGN KEY (recipient_user_id) REFERENCES users(user_id),
    CONSTRAINT fk_notifications_created_by FOREIGN KEY (created_by) REFERENCES users(user_id),
    CONSTRAINT fk_notifications_updated_by FOREIGN KEY (updated_by) REFERENCES users(user_id)
);

-- =============================================================
-- Indexes
-- =============================================================

CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);

CREATE INDEX idx_vendors_status ON vendors(status);
CREATE INDEX idx_vendors_risk_rating ON vendors(risk_rating);
CREATE INDEX idx_vendor_contacts_vendor ON vendor_contacts(vendor_id);
CREATE INDEX idx_vendor_bank_accounts_vendor ON vendor_bank_accounts(vendor_id);

CREATE INDEX idx_items_category ON items(item_category_id);
CREATE INDEX idx_items_type_active ON items(item_type, is_active);
CREATE INDEX idx_warehouse_locations_warehouse ON warehouse_locations(warehouse_id);

CREATE INDEX idx_contracts_vendor_status ON contracts(vendor_id, status);
CREATE INDEX idx_contracts_expiration_date ON contracts(expiration_date);
CREATE INDEX idx_contract_lines_contract ON contract_lines(contract_id);
CREATE INDEX idx_contract_lines_item ON contract_lines(item_id);

CREATE INDEX idx_pr_requester_status ON purchase_requisitions(requester_user_id, status);
CREATE INDEX idx_pr_status_created_at ON purchase_requisitions(status, created_at);
CREATE INDEX idx_pr_lines_pr ON purchase_requisition_lines(pr_id);
CREATE INDEX idx_pr_lines_item ON purchase_requisition_lines(item_id);

CREATE INDEX idx_rfqs_pr ON rfqs(pr_id);
CREATE INDEX idx_rfqs_buyer_status ON rfqs(buyer_user_id, status);
CREATE INDEX idx_rfq_lines_rfq ON rfq_lines(rfq_id);
CREATE INDEX idx_rfq_vendor_invites_vendor ON rfq_vendor_invites(vendor_id);
CREATE INDEX idx_rfq_responses_vendor_status ON rfq_responses(vendor_id, status);
CREATE INDEX idx_rfq_response_lines_rfq_line ON rfq_response_lines(rfq_line_id);

CREATE INDEX idx_po_vendor_status ON purchase_orders(vendor_id, status);
CREATE INDEX idx_po_buyer_status ON purchase_orders(buyer_user_id, status);
CREATE INDEX idx_po_order_date ON purchase_orders(order_date);
CREATE INDEX idx_po_lines_po ON purchase_order_lines(po_id);
CREATE INDEX idx_po_lines_item ON purchase_order_lines(item_id);
CREATE INDEX idx_goods_receipts_po ON goods_receipts(po_id);
CREATE INDEX idx_gr_lines_po_line ON goods_receipt_lines(po_line_id);

CREATE INDEX idx_invoices_vendor_status ON invoices(vendor_id, status);
CREATE INDEX idx_invoices_po ON invoices(po_id);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);
CREATE INDEX idx_invoice_lines_invoice ON invoice_lines(invoice_id);
CREATE INDEX idx_invoice_lines_po_line ON invoice_lines(po_line_id);

CREATE INDEX idx_inventory_balances_item ON inventory_balances(item_id);
CREATE INDEX idx_inventory_balances_warehouse_location ON inventory_balances(warehouse_id, warehouse_location_id);
CREATE INDEX idx_inventory_transactions_item_date ON inventory_transactions(item_id, transaction_at);
CREATE INDEX idx_inventory_transactions_reference ON inventory_transactions(reference_type, reference_id);

CREATE INDEX idx_approval_workflows_entity ON approval_workflows(entity_type, is_active);
CREATE INDEX idx_approval_steps_workflow ON approval_steps(workflow_id);
CREATE INDEX idx_approval_tasks_assignee_status ON approval_tasks(assigned_to_user_id, status);
CREATE INDEX idx_approval_tasks_entity ON approval_tasks(entity_type, entity_id);
CREATE INDEX idx_approval_tasks_due_at ON approval_tasks(due_at);

CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_actor_created_at ON audit_logs(actor_user_id, created_at);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_changed_fields_gin ON audit_logs USING gin (changed_fields);

CREATE INDEX idx_notifications_recipient_status ON notifications(recipient_user_id, delivery_status);
CREATE INDEX idx_notifications_unread ON notifications(recipient_user_id, created_at) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_entity ON notifications(entity_type, entity_id);

-- =============================================================
-- Sample Records
-- =============================================================

INSERT INTO users (user_id, employee_no, username, email, password_hash, first_name, last_name, department, status)
VALUES
('00000000-0000-0000-0000-000000000001', 'EMP-0001', 'admin', 'admin@example.com', '$2a$12$samplehash', 'System', 'Administrator', 'IT', 'ACTIVE'),
('00000000-0000-0000-0000-000000000002', 'EMP-0002', 'buyer01', 'buyer01@example.com', '$2a$12$samplehash', 'Bianca', 'Buyer', 'Procurement', 'ACTIVE'),
('00000000-0000-0000-0000-000000000003', 'EMP-0003', 'requester01', 'requester01@example.com', '$2a$12$samplehash', 'Ravi', 'Requester', 'Operations', 'ACTIVE'),
('00000000-0000-0000-0000-000000000004', 'EMP-0004', 'approver01', 'approver01@example.com', '$2a$12$samplehash', 'Ava', 'Approver', 'Finance', 'ACTIVE'),
('00000000-0000-0000-0000-000000000005', 'EMP-0005', 'warehouse01', 'warehouse01@example.com', '$2a$12$samplehash', 'Wade', 'Warehouse', 'Logistics', 'ACTIVE');

INSERT INTO roles (role_id, role_code, role_name, description, created_by)
VALUES
('10000000-0000-0000-0000-000000000001', 'PROC_ADMIN', 'Procurement Administrator', 'Full procurement administration role', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000002', 'BUYER', 'Buyer', 'Creates RFQs and purchase orders', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000003', 'REQUESTER', 'Requester', 'Creates purchase requisitions', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000004', 'APPROVER', 'Approver', 'Approves procurement documents', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000005', 'WAREHOUSE_MANAGER', 'Warehouse Manager', 'Posts goods receipts and inventory transactions', '00000000-0000-0000-0000-000000000001');

INSERT INTO permissions (permission_id, permission_code, permission_name, module_name, created_by)
VALUES
('11000000-0000-0000-0000-000000000001', 'PR_CREATE', 'Create Purchase Requisition', 'Purchase Requisition', '00000000-0000-0000-0000-000000000001'),
('11000000-0000-0000-0000-000000000002', 'RFQ_MANAGE', 'Manage RFQ', 'RFQ', '00000000-0000-0000-0000-000000000001'),
('11000000-0000-0000-0000-000000000003', 'PO_CREATE', 'Create Purchase Order', 'Purchase Order', '00000000-0000-0000-0000-000000000001'),
('11000000-0000-0000-0000-000000000004', 'APPROVE_DOCUMENT', 'Approve Document', 'Approval Workflow', '00000000-0000-0000-0000-000000000001'),
('11000000-0000-0000-0000-000000000005', 'GRN_POST', 'Post Goods Receipt', 'Warehouse', '00000000-0000-0000-0000-000000000001');

INSERT INTO user_roles (user_id, role_id, assigned_by)
VALUES
('00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001');

INSERT INTO role_permissions (role_id, permission_id, granted_by)
VALUES
('10000000-0000-0000-0000-000000000003', '11000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000002', '11000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000002', '11000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000004', '11000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001'),
('10000000-0000-0000-0000-000000000005', '11000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001');

INSERT INTO vendors (vendor_id, vendor_code, legal_name, tax_identifier, vendor_type, status, risk_rating, payment_terms, currency_code, city, state_province, country_code, created_by)
VALUES ('20000000-0000-0000-0000-000000000001', 'VEND-ACME-001', 'Acme Industrial Supplies LLC', 'US-TAX-123456', 'DISTRIBUTOR', 'APPROVED', 'LOW', 'NET30', 'USD', 'Chicago', 'IL', 'US', '00000000-0000-0000-0000-000000000001');

INSERT INTO vendor_contacts (vendor_contact_id, vendor_id, contact_name, email, phone, job_title, is_primary, created_by)
VALUES ('21000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Sam Supplier', 'sam.supplier@acme.example', '+1-312-555-0100', 'Account Manager', true, '00000000-0000-0000-0000-000000000001');

INSERT INTO vendor_bank_accounts (vendor_bank_account_id, vendor_id, bank_name, account_name, account_number_masked, routing_number, currency_code, verification_status, created_by)
VALUES ('22000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'Enterprise Bank', 'Acme Industrial Supplies LLC', '****6789', '021000021', 'USD', 'VERIFIED', '00000000-0000-0000-0000-000000000001');

INSERT INTO item_categories (item_category_id, category_code, category_name, description, created_by)
VALUES ('30000000-0000-0000-0000-000000000001', 'MRO', 'Maintenance, Repair, and Operations', 'MRO supplies and consumables', '00000000-0000-0000-0000-000000000001');

INSERT INTO items (item_id, item_category_id, sku, item_name, item_type, uom, standard_cost, currency_code, reorder_point, lead_time_days, created_by)
VALUES ('31000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'MRO-GLOVE-NITRILE-M', 'Nitrile Gloves Medium', 'MATERIAL', 'BOX', 12.5000, 'USD', 100.0000, 7, '00000000-0000-0000-0000-000000000001');

INSERT INTO warehouses (warehouse_id, warehouse_code, warehouse_name, city, state_province, country_code, created_by)
VALUES ('32000000-0000-0000-0000-000000000001', 'WH-CHI-01', 'Chicago Main Warehouse', 'Chicago', 'IL', 'US', '00000000-0000-0000-0000-000000000001');

INSERT INTO warehouse_locations (warehouse_location_id, warehouse_id, location_code, location_name, location_type, created_by)
VALUES ('33000000-0000-0000-0000-000000000001', '32000000-0000-0000-0000-000000000001', 'REC-01', 'Receiving Dock 01', 'RECEIVING', '00000000-0000-0000-0000-000000000001');

INSERT INTO contracts (contract_id, contract_number, vendor_id, contract_title, contract_type, status, effective_date, expiration_date, contract_value, currency_code, owner_user_id, created_by)
VALUES ('40000000-0000-0000-0000-000000000001', 'CON-2026-0001', '20000000-0000-0000-0000-000000000001', 'MRO Supplies Master Agreement', 'MASTER_SERVICE_AGREEMENT', 'ACTIVE', '2026-01-01', '2026-12-31', 500000.0000, 'USD', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001');

INSERT INTO contract_lines (contract_line_id, contract_id, item_id, line_number, description, uom, committed_quantity, unit_price, release_limit_amount, created_by)
VALUES ('41000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '31000000-0000-0000-0000-000000000001', 1, 'Contracted nitrile gloves', 'BOX', 10000.0000, 11.7500, 150000.0000, '00000000-0000-0000-0000-000000000001');

INSERT INTO purchase_requisitions (pr_id, pr_number, requester_user_id, department, cost_center, status, required_by_date, currency_code, total_amount, business_justification, created_by)
VALUES ('50000000-0000-0000-0000-000000000001', 'PR-2026-0001', '00000000-0000-0000-0000-000000000003', 'Operations', 'OPS-100', 'APPROVED', '2026-06-15', 'USD', 1175.0000, 'Replenish safety supplies', '00000000-0000-0000-0000-000000000003');

INSERT INTO purchase_requisition_lines (pr_line_id, pr_id, line_number, item_id, description, quantity, uom, estimated_unit_price, estimated_line_amount, gl_account, cost_center, required_by_date, created_by)
VALUES ('51000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', 1, '31000000-0000-0000-0000-000000000001', 'Nitrile Gloves Medium', 100.0000, 'BOX', 11.7500, 1175.0000, '640000', 'OPS-100', '2026-06-15', '00000000-0000-0000-0000-000000000003');

INSERT INTO rfqs (rfq_id, rfq_number, pr_id, rfq_title, buyer_user_id, status, issue_date, response_due_date, currency_code, created_by)
VALUES ('60000000-0000-0000-0000-000000000001', 'RFQ-2026-0001', '50000000-0000-0000-0000-000000000001', 'MRO Gloves RFQ', '00000000-0000-0000-0000-000000000002', 'AWARDED', '2026-05-20', '2026-05-25 17:00:00+00', 'USD', '00000000-0000-0000-0000-000000000002');

INSERT INTO rfq_lines (rfq_line_id, rfq_id, pr_line_id, line_number, item_id, description, quantity, uom, created_by)
VALUES ('61000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', 1, '31000000-0000-0000-0000-000000000001', 'Nitrile Gloves Medium', 100.0000, 'BOX', '00000000-0000-0000-0000-000000000002');

INSERT INTO rfq_vendor_invites (rfq_vendor_invite_id, rfq_id, vendor_id, invite_status, created_by)
VALUES ('62000000-0000-0000-0000-000000000001', '60000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'RESPONDED', '00000000-0000-0000-0000-000000000002');

INSERT INTO rfq_responses (rfq_response_id, rfq_vendor_invite_id, vendor_id, status, submitted_at, total_amount, currency_code, payment_terms, validity_date, created_by)
VALUES ('63000000-0000-0000-0000-000000000001', '62000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'AWARDED', now(), 1175.0000, 'USD', 'NET30', '2026-06-30', '00000000-0000-0000-0000-000000000002');

INSERT INTO rfq_response_lines (rfq_response_line_id, rfq_response_id, rfq_line_id, unit_price, quantity, line_amount, lead_time_days, notes, created_by)
VALUES ('64000000-0000-0000-0000-000000000001', '63000000-0000-0000-0000-000000000001', '61000000-0000-0000-0000-000000000001', 11.7500, 100.0000, 1175.0000, 7, 'Contract price honored', '00000000-0000-0000-0000-000000000002');

INSERT INTO purchase_orders (po_id, po_number, vendor_id, pr_id, contract_id, buyer_user_id, status, order_date, expected_delivery_date, currency_code, subtotal_amount, tax_amount, total_amount, ship_to_warehouse_id, payment_terms, created_by)
VALUES ('70000000-0000-0000-0000-000000000001', 'PO-2026-0001', '20000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-000000000001', '40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'RECEIVED', '2026-05-26', '2026-06-05', 'USD', 1175.0000, 94.0000, 1269.0000, '32000000-0000-0000-0000-000000000001', 'NET30', '00000000-0000-0000-0000-000000000002');

INSERT INTO purchase_order_lines (po_line_id, po_id, pr_line_id, contract_line_id, line_number, item_id, description, quantity, received_quantity, invoiced_quantity, uom, unit_price, line_amount, tax_amount, created_by)
VALUES ('71000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001', '51000000-0000-0000-0000-000000000001', '41000000-0000-0000-0000-000000000001', 1, '31000000-0000-0000-0000-000000000001', 'Nitrile Gloves Medium', 100.0000, 100.0000, 100.0000, 'BOX', 11.7500, 1175.0000, 94.0000, '00000000-0000-0000-0000-000000000002');

INSERT INTO goods_receipts (goods_receipt_id, grn_number, po_id, warehouse_id, received_by_user_id, receipt_date, status, notes, created_by)
VALUES ('80000000-0000-0000-0000-000000000001', 'GRN-2026-0001', '70000000-0000-0000-0000-000000000001', '32000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000005', '2026-06-03', 'POSTED', 'Received in full', '00000000-0000-0000-0000-000000000005');

INSERT INTO goods_receipt_lines (goods_receipt_line_id, goods_receipt_id, po_line_id, warehouse_location_id, received_quantity, accepted_quantity, rejected_quantity, quality_status, created_by)
VALUES ('81000000-0000-0000-0000-000000000001', '80000000-0000-0000-0000-000000000001', '71000000-0000-0000-0000-000000000001', '33000000-0000-0000-0000-000000000001', 100.0000, 100.0000, 0.0000, 'ACCEPTED', '00000000-0000-0000-0000-000000000005');

INSERT INTO inventory_balances (inventory_balance_id, item_id, warehouse_id, warehouse_location_id, on_hand_quantity, reserved_quantity, available_quantity, created_by)
VALUES ('82000000-0000-0000-0000-000000000001', '31000000-0000-0000-0000-000000000001', '32000000-0000-0000-0000-000000000001', '33000000-0000-0000-0000-000000000001', 100.0000, 0.0000, 100.0000, '00000000-0000-0000-0000-000000000005');

INSERT INTO inventory_transactions (inventory_transaction_id, item_id, warehouse_id, warehouse_location_id, transaction_type, quantity, reference_type, reference_id, goods_receipt_line_id, created_by)
VALUES ('83000000-0000-0000-0000-000000000001', '31000000-0000-0000-0000-000000000001', '32000000-0000-0000-0000-000000000001', '33000000-0000-0000-0000-000000000001', 'RECEIPT', 100.0000, 'GOODS_RECEIPT', '80000000-0000-0000-0000-000000000001', '81000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000005');

INSERT INTO invoices (invoice_id, invoice_number, vendor_id, po_id, invoice_date, due_date, status, match_status, currency_code, subtotal_amount, tax_amount, total_amount, created_by)
VALUES ('90000000-0000-0000-0000-000000000001', 'INV-ACME-2026-0001', '20000000-0000-0000-0000-000000000001', '70000000-0000-0000-0000-000000000001', '2026-06-04', '2026-07-04', 'APPROVED', 'MATCHED', 'USD', 1175.0000, 94.0000, 1269.0000, '00000000-0000-0000-0000-000000000002');

INSERT INTO invoice_lines (invoice_line_id, invoice_id, po_line_id, line_number, item_id, description, quantity, uom, unit_price, line_amount, tax_amount, match_variance_amount, created_by)
VALUES ('91000000-0000-0000-0000-000000000001', '90000000-0000-0000-0000-000000000001', '71000000-0000-0000-0000-000000000001', 1, '31000000-0000-0000-0000-000000000001', 'Nitrile Gloves Medium', 100.0000, 'BOX', 11.7500, 1175.0000, 94.0000, 0.0000, '00000000-0000-0000-0000-000000000002');

INSERT INTO approval_workflows (workflow_id, workflow_code, workflow_name, entity_type, min_amount, max_amount, currency_code, created_by)
VALUES ('a0000000-0000-0000-0000-000000000001', 'PR_STD_USD', 'Standard PR Approval USD', 'PR', 0.0000, 10000.0000, 'USD', '00000000-0000-0000-0000-000000000001');

INSERT INTO approval_steps (approval_step_id, workflow_id, step_sequence, step_name, approver_role_id, approval_type, escalation_hours, created_by)
VALUES ('a1000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 1, 'Finance Approval', '10000000-0000-0000-0000-000000000004', 'ANY_ONE', 48, '00000000-0000-0000-0000-000000000001');

INSERT INTO approval_tasks (approval_task_id, workflow_id, approval_step_id, entity_type, entity_id, assigned_to_user_id, status, decision, comments, decided_at, due_at, created_by)
VALUES ('a2000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'PR', '50000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000004', 'APPROVED', 'APPROVE', 'Approved within budget', now(), now() + interval '48 hours', '00000000-0000-0000-0000-000000000004');

INSERT INTO notifications (notification_id, recipient_user_id, notification_type, subject, message, entity_type, entity_id, delivery_status, sent_at, created_by)
VALUES ('b0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000003', 'IN_APP', 'Purchase Requisition Approved', 'PR-2026-0001 has been approved.', 'PR', '50000000-0000-0000-0000-000000000001', 'SENT', now(), '00000000-0000-0000-0000-000000000004');

INSERT INTO audit_logs (audit_log_id, entity_type, entity_id, action, actor_user_id, changed_fields, old_values, new_values, ip_address, user_agent, correlation_id)
VALUES ('c0000000-0000-0000-0000-000000000001', 'PR', '50000000-0000-0000-0000-000000000001', 'APPROVED', '00000000-0000-0000-0000-000000000004', '{"status": true}'::jsonb, '{"status": "SUBMITTED"}'::jsonb, '{"status": "APPROVED"}'::jsonb, '10.0.0.10', 'sample-agent', gen_random_uuid());
