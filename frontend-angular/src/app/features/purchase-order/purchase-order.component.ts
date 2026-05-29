import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { PurchaseOrder } from '../../core/models/procurement.model';
import { PurchaseOrderService } from './purchase-order.service';

@Component({
  selector: 'epro-purchase-order',
  standalone: true,
  imports: [CurrencyPipe, DatePipe, ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatTableModule],
  template: `
    <section class="page"><div class="page-header"><div><h1 class="page-title">Purchase Order</h1><p class="page-subtitle">Track supplier commitments, dispatch status, delivery and closeout.</p></div><button mat-flat-button color="primary" [disabled]="form.invalid">Create PO</button></div>
      <mat-card><mat-card-content><form [formGroup]="form" class="form-grid">
        <mat-form-field appearance="outline"><mat-label>PO Number</mat-label><input matInput formControlName="poNumber"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Vendor ID</mat-label><input matInput formControlName="vendorId"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Buyer ID</mat-label><input matInput formControlName="buyerUserId"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Order Date</mat-label><input matInput type="date" formControlName="orderDate"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Payment Terms</mat-label><mat-select formControlName="paymentTerms"><mat-option value="NET30">NET30</mat-option><mat-option value="NET45">NET45</mat-option></mat-select></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Total Amount</mat-label><input matInput type="number" formControlName="totalAmount"></mat-form-field>
      </form></mat-card-content></mat-card>
      <mat-card class="table-card"><table mat-table [dataSource]="orders()">
        <ng-container matColumnDef="poNumber"><th mat-header-cell *matHeaderCellDef>PO</th><td mat-cell *matCellDef="let row">{{ row.poNumber }}</td></ng-container>
        <ng-container matColumnDef="status"><th mat-header-cell *matHeaderCellDef>Status</th><td mat-cell *matCellDef="let row"><span class="status-chip">{{ row.status }}</span></td></ng-container>
        <ng-container matColumnDef="orderDate"><th mat-header-cell *matHeaderCellDef>Order Date</th><td mat-cell *matCellDef="let row">{{ row.orderDate | date }}</td></ng-container>
        <ng-container matColumnDef="totalAmount"><th mat-header-cell *matHeaderCellDef>Total</th><td mat-cell *matCellDef="let row">{{ row.totalAmount | currency }}</td></ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr><tr mat-row *matRowDef="let row; columns: columns"></tr>
      </table></mat-card>
    </section>`
})
export class PurchaseOrderComponent {
  private readonly fb = inject(FormBuilder);
  private readonly service = inject(PurchaseOrderService);
  readonly orders = signal<PurchaseOrder[]>([]);
  readonly columns = ['poNumber', 'status', 'orderDate', 'totalAmount'];
  readonly form = this.fb.nonNullable.group({ poNumber: ['', Validators.required], vendorId: ['', Validators.required], buyerUserId: ['', Validators.required], orderDate: ['', Validators.required], paymentTerms: ['NET30', Validators.required], totalAmount: [0, Validators.min(0)] });
  constructor() { this.service.list().subscribe({ next: orders => this.orders.set(orders), error: () => this.orders.set([]) }); }
}
