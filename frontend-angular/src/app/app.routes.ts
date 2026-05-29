import { Routes } from '@angular/router';
import { authChildGuard, authGuard } from './core/guards/auth.guard';
import { ShellComponent } from './shared/layout/shell.component';

export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./features/login/login.component').then(m => m.LoginComponent) },
  {
    path: '',
    component: ShellComponent,
    canActivate: [authGuard],
    canActivateChild: [authChildGuard],
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
      { path: 'dashboard', loadComponent: () => import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent) },
      { path: 'users', loadComponent: () => import('./features/user-management/user-management.component').then(m => m.UserManagementComponent) },
      { path: 'vendors', loadComponent: () => import('./features/vendor-management/vendor-management.component').then(m => m.VendorManagementComponent) },
      { path: 'purchase-requisitions', loadComponent: () => import('./features/purchase-requisition/purchase-requisition.component').then(m => m.PurchaseRequisitionComponent) },
      { path: 'rfqs', loadComponent: () => import('./features/rfq/rfq.component').then(m => m.RfqComponent) },
      { path: 'purchase-orders', loadComponent: () => import('./features/purchase-order/purchase-order.component').then(m => m.PurchaseOrderComponent) },
      { path: 'inventory', loadComponent: () => import('./features/inventory/inventory.component').then(m => m.InventoryComponent) },
      { path: 'invoices', loadComponent: () => import('./features/invoice/invoice.component').then(m => m.InvoiceComponent) },
      { path: 'reports', loadComponent: () => import('./features/reports/reports.component').then(m => m.ReportsComponent) }
    ]
  },
  { path: '**', redirectTo: 'dashboard' }
];
