import { BreakpointObserver } from '@angular/cdk/layout';
import { Component, inject, signal } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { AuthService } from '../../core/services/auth.service';

interface NavigationItem { path: string; icon: string; label: string; }

@Component({
  selector: 'epro-shell',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, MatButtonModule, MatIconModule, MatListModule, MatSidenavModule, MatToolbarModule],
  template: `
    <mat-sidenav-container class="shell">
      <mat-sidenav #drawer class="sidenav" [mode]="isHandset() ? 'over' : 'side'" [opened]="!isHandset()">
        <div class="brand"><mat-icon>shopping_cart</mat-icon><span>E‑Procurement ERP</span></div>
        <mat-nav-list>
          @for (item of navItems; track item.path) {
            <a mat-list-item [routerLink]="item.path" routerLinkActive="active" (click)="isHandset() && drawer.close()">
              <mat-icon matListItemIcon>{{ item.icon }}</mat-icon>
              <span matListItemTitle>{{ item.label }}</span>
            </a>
          }
        </mat-nav-list>
      </mat-sidenav>
      <mat-sidenav-content>
        <mat-toolbar class="toolbar">
          <button mat-icon-button (click)="drawer.toggle()" aria-label="Toggle navigation"><mat-icon>menu</mat-icon></button>
          <span class="spacer"></span>
          <span class="user">{{ auth.currentUser()?.username || 'User' }}</span>
          <button mat-button (click)="auth.logout()"><mat-icon>logout</mat-icon> Logout</button>
        </mat-toolbar>
        <main><router-outlet /></main>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styles: [`
    .shell { min-height: 100vh; }
    .sidenav { width: 280px; border-right: 0; background: #101828; color: #fff; }
    .brand { display: flex; align-items: center; gap: 12px; padding: 22px; font-weight: 800; font-size: 18px; }
    .brand mat-icon { color: #7dd3fc; }
    a[mat-list-item] { color: #dbe7ff; margin: 4px 10px; width: calc(100% - 20px); border-radius: 12px; }
    a[mat-list-item].active, a[mat-list-item]:hover { background: rgba(125, 211, 252, .16); color: #fff; }
    .toolbar { position: sticky; top: 0; z-index: 10; background: #fff; border-bottom: 1px solid #e5eaf2; }
    .spacer { flex: 1; }
    .user { font-weight: 700; margin-right: 12px; color: #344054; }
    main { min-height: calc(100vh - 64px); }
  `]
})
export class ShellComponent {
  readonly auth = inject(AuthService);
  readonly isHandset = signal(false);
  readonly navItems: NavigationItem[] = [
    { path: '/dashboard', icon: 'dashboard', label: 'Dashboard' },
    { path: '/users', icon: 'group', label: 'User Management' },
    { path: '/vendors', icon: 'storefront', label: 'Vendor Management' },
    { path: '/purchase-requisitions', icon: 'assignment', label: 'Purchase Requisition' },
    { path: '/rfqs', icon: 'request_quote', label: 'RFQ' },
    { path: '/purchase-orders', icon: 'receipt_long', label: 'Purchase Order' },
    { path: '/inventory', icon: 'inventory_2', label: 'Inventory' },
    { path: '/invoices', icon: 'payments', label: 'Invoice' },
    { path: '/reports', icon: 'bar_chart', label: 'Reports' }
  ];

  constructor() {
    inject(BreakpointObserver).observe('(max-width: 900px)').subscribe(result => this.isHandset.set(result.matches));
  }
}
