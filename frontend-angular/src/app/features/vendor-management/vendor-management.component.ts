import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { Vendor } from '../../core/models/procurement.model';
import { VendorManagementService } from './vendor-management.service';

@Component({
  selector: 'epro-vendor-management',
  standalone: true,
  imports: [ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatTableModule],
  template: `
    <section class="page"><div class="page-header"><div><h1 class="page-title">Vendor Management</h1><p class="page-subtitle">Onboard, qualify and manage supplier master data.</p></div><button mat-flat-button color="primary" (click)="create()" [disabled]="form.invalid">Create Vendor</button></div>
      <mat-card><mat-card-content><form [formGroup]="form" class="form-grid">
        <mat-form-field appearance="outline"><mat-label>Vendor Code</mat-label><input matInput formControlName="vendorCode"><mat-error>Required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Legal Name</mat-label><input matInput formControlName="legalName"><mat-error>Required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Tax Identifier</mat-label><input matInput formControlName="taxIdentifier"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Vendor Type</mat-label><mat-select formControlName="vendorType"><mat-option value="DISTRIBUTOR">Distributor</mat-option><mat-option value="MANUFACTURER">Manufacturer</mat-option><mat-option value="SERVICE_PROVIDER">Service Provider</mat-option></mat-select></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Currency</mat-label><input matInput formControlName="currencyCode" maxlength="3"><mat-error>Use ISO 4217 code</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Country</mat-label><input matInput formControlName="countryCode" maxlength="2"></mat-form-field>
      </form></mat-card-content></mat-card>
      <mat-card class="table-card"><table mat-table [dataSource]="vendors()">
        <ng-container matColumnDef="vendorCode"><th mat-header-cell *matHeaderCellDef>Code</th><td mat-cell *matCellDef="let row">{{ row.vendorCode }}</td></ng-container>
        <ng-container matColumnDef="legalName"><th mat-header-cell *matHeaderCellDef>Legal Name</th><td mat-cell *matCellDef="let row">{{ row.legalName }}</td></ng-container>
        <ng-container matColumnDef="vendorType"><th mat-header-cell *matHeaderCellDef>Type</th><td mat-cell *matCellDef="let row">{{ row.vendorType }}</td></ng-container>
        <ng-container matColumnDef="riskRating"><th mat-header-cell *matHeaderCellDef>Risk</th><td mat-cell *matCellDef="let row">{{ row.riskRating }}</td></ng-container>
        <ng-container matColumnDef="status"><th mat-header-cell *matHeaderCellDef>Status</th><td mat-cell *matCellDef="let row"><span class="status-chip">{{ row.status }}</span></td></ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr><tr mat-row *matRowDef="let row; columns: columns"></tr>
      </table></mat-card>
    </section>`
})
export class VendorManagementComponent {
  private readonly service = inject(VendorManagementService);
  private readonly fb = inject(FormBuilder);
  readonly vendors = signal<Vendor[]>([]);
  readonly columns = ['vendorCode', 'legalName', 'vendorType', 'riskRating', 'status'];
  readonly form = this.fb.nonNullable.group({ vendorCode: ['', Validators.required], legalName: ['', Validators.required], taxIdentifier: [''], vendorType: ['DISTRIBUTOR', Validators.required], currencyCode: ['USD', [Validators.required, Validators.pattern('[A-Z]{3}')]], countryCode: ['US', Validators.pattern('[A-Z]{2}')] });
  constructor() { this.load(); }
  create(): void { if (this.form.invalid) return; this.service.create(this.form.getRawValue()).subscribe(vendor => this.vendors.update(vendors => [vendor, ...vendors])); }
  private load(): void { this.service.list().subscribe({ next: vendors => this.vendors.set(vendors), error: () => this.vendors.set([]) }); }
}
