import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { Invoice } from '../../core/models/procurement.model';
import { InvoiceService } from './invoice.service';

@Component({
  selector: 'epro-invoice',
  standalone: true,
  imports: [CurrencyPipe, DatePipe, ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatTableModule],
  template: `
    <section class="page"><div class="page-header"><div><h1 class="page-title">Invoice</h1><p class="page-subtitle">Capture supplier invoices, monitor 3-way match and resolve exceptions.</p></div><button mat-flat-button color="primary" [disabled]="form.invalid">Register Invoice</button></div>
      <mat-card><mat-card-content><form [formGroup]="form" class="form-grid">
        <mat-form-field appearance="outline"><mat-label>Invoice Number</mat-label><input matInput formControlName="invoiceNumber"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Vendor ID</mat-label><input matInput formControlName="vendorId"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>PO ID</mat-label><input matInput formControlName="purchaseOrderId"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Invoice Date</mat-label><input matInput type="date" formControlName="invoiceDate"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Currency</mat-label><mat-select formControlName="currency"><mat-option value="USD">USD</mat-option><mat-option value="EUR">EUR</mat-option></mat-select></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Total Amount</mat-label><input matInput type="number" formControlName="totalAmount"></mat-form-field>
      </form></mat-card-content></mat-card>
      <mat-card class="table-card"><table mat-table [dataSource]="invoices()">
        <ng-container matColumnDef="invoiceNumber"><th mat-header-cell *matHeaderCellDef>Invoice</th><td mat-cell *matCellDef="let row">{{ row.invoiceNumber }}</td></ng-container>
        <ng-container matColumnDef="invoiceDate"><th mat-header-cell *matHeaderCellDef>Date</th><td mat-cell *matCellDef="let row">{{ row.invoiceDate | date }}</td></ng-container>
        <ng-container matColumnDef="matchStatus"><th mat-header-cell *matHeaderCellDef>Match</th><td mat-cell *matCellDef="let row">{{ row.matchStatus }}</td></ng-container>
        <ng-container matColumnDef="status"><th mat-header-cell *matHeaderCellDef>Status</th><td mat-cell *matCellDef="let row"><span class="status-chip">{{ row.status }}</span></td></ng-container>
        <ng-container matColumnDef="totalAmount"><th mat-header-cell *matHeaderCellDef>Total</th><td mat-cell *matCellDef="let row">{{ row.totalAmount | currency }}</td></ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr><tr mat-row *matRowDef="let row; columns: columns"></tr>
      </table></mat-card>
    </section>`
})
export class InvoiceComponent {
  private readonly fb = inject(FormBuilder);
  private readonly service = inject(InvoiceService);
  readonly invoices = signal<Invoice[]>([]);
  readonly columns = ['invoiceNumber', 'invoiceDate', 'matchStatus', 'status', 'totalAmount'];
  readonly form = this.fb.nonNullable.group({ invoiceNumber: ['', Validators.required], vendorId: ['', Validators.required], purchaseOrderId: [''], invoiceDate: ['', Validators.required], currency: ['USD', Validators.required], totalAmount: [0, Validators.min(0)] });
  constructor() { this.service.list().subscribe({ next: invoices => this.invoices.set(invoices), error: () => this.invoices.set([]) }); }
}
