# Phase 4: Angular 20 Frontend Generation

## 1. Enterprise Frontend Structure

```text
frontend-angular/
├── angular.json
├── package.json
├── tsconfig*.json
└── src/
    ├── main.ts
    ├── styles.scss
    ├── environments/environment.ts
    └── app/
        ├── app.component.ts
        ├── app.config.ts
        ├── app.routes.ts
        ├── core/
        │   ├── guards/auth.guard.ts
        │   ├── interceptors/auth.interceptor.ts
        │   ├── models/
        │   └── services/
        ├── shared/layout/shell.component.ts
        └── features/
            ├── login/
            ├── dashboard/
            ├── user-management/
            ├── vendor-management/
            ├── purchase-requisition/
            ├── rfq/
            ├── purchase-order/
            ├── inventory/
            ├── invoice/
            └── reports/
```

## 2. Technology Coverage

| Requirement | Implementation |
| --- | --- |
| Angular 20 | Standalone application configured in `package.json`, `angular.json`, `app.config.ts` |
| TypeScript | Strict TypeScript and Angular template checks in `tsconfig.json` |
| Angular Material | Material toolbar, sidenav, cards, forms, tables, buttons, icons and selects |
| Reactive Forms | Validated forms across login, users, vendors, PR, RFQ, PO, inventory and invoice pages |
| JWT authentication | Login service, local storage token handling, interceptor and route guard |
| Routing | Lazy route configuration for all feature pages |
| Charts | `ng2-charts` / Chart.js dashboard and reporting charts |
| API integration | Shared API client plus feature services for backend endpoints |
| Responsive design | Global grid utilities, responsive sidenav and mobile form/table layouts |

## 3. Generated Pages

- Login: JWT login form with validation, loading and error state.
- Dashboard: Executive KPIs and spend/pipeline charts.
- User Management: User invitation form and RBAC table.
- Vendor Management: Vendor onboarding form, validation and API integration.
- Purchase Requisition: Header/line reactive form, amount calculation integration and submit action.
- RFQ: Sourcing event form and RFQ pipeline table.
- Purchase Order: PO entry layout and PO tracking table.
- Inventory: Stock adjustment form and inventory availability table.
- Invoice: Invoice registration layout and match-status table.
- Reports: KPI cards and chart-based spend/risk analytics.

## 4. API Integration Pattern

- `ApiClientService` normalizes the backend `ApiResponse<T>` envelope.
- `authInterceptor` adds `Authorization: Bearer <token>` to API requests.
- Feature services isolate endpoint details from components.
- Components use signals for local page state and reactive forms for validation.

## 5. Validation and UX Standards

- Required fields use Material error messages.
- Currency fields validate ISO 4217 format.
- Country fields validate ISO 3166-1 alpha-2 format.
- Quantity and amount fields enforce non-negative or positive values.
- Page layout uses reusable `page`, `grid`, `form-grid`, `table-card`, `status-chip` classes.
