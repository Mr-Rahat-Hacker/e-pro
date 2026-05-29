export type DocumentStatus = 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED' | 'CANCELLED' | 'CONVERTED' | 'ISSUED' | 'RECEIVED' | 'CLOSED';
export type VendorStatus = 'DRAFT' | 'APPROVED' | 'BLOCKED' | 'INACTIVE';

export interface User { id: string; employeeNo: string; username: string; email: string; firstName: string; lastName: string; department?: string; status: string; roles: string[]; }
export interface Vendor { id: string; vendorCode: string; legalName: string; vendorType: string; status: VendorStatus; riskRating: string; currencyCode: string; countryCode?: string; }
export interface VendorCreateRequest { vendorCode: string; legalName: string; taxIdentifier?: string; vendorType: string; currencyCode: string; countryCode?: string; }
export interface PurchaseRequisitionLine { id?: string; itemId?: string; description: string; quantity: number; uom: string; estimatedUnitPrice: number; estimatedLineAmount?: number; requiredByDate?: string; }
export interface PurchaseRequisition { id: string; prNumber: string; requesterUserId: string; status: DocumentStatus; currencyCode: string; totalAmount: number; lines: PurchaseRequisitionLine[]; }
export interface PurchaseRequisitionCreateRequest { prNumber: string; requesterUserId: string; department?: string; costCenter?: string; requiredByDate?: string; currencyCode: string; businessJustification?: string; lines: PurchaseRequisitionLine[]; }
export interface Rfq { id: string; rfqNumber: string; title: string; status: DocumentStatus; dueDate: string; invitedVendors: number; estimatedValue: number; }
export interface PurchaseOrder { id: string; poNumber: string; vendorId: string; buyerUserId: string; status: DocumentStatus; orderDate: string; totalAmount: number; }
export interface InventoryItem { id: string; sku: string; itemName: string; warehouse: string; onHandQuantity: number; reservedQuantity: number; availableQuantity: number; reorderPoint: number; }
export interface Invoice { id: string; invoiceNumber: string; vendorId: string; purchaseOrderId?: string; invoiceDate: string; status: DocumentStatus; matchStatus: string; totalAmount: number; }
export interface ReportKpi { label: string; value: string | number; trend: string; }
