import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { InventoryItem } from '../../core/models/procurement.model';
import { InventoryService } from './inventory.service';

@Component({
  selector: 'epro-inventory',
  standalone: true,
  imports: [ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatTableModule],
  template: `
    <section class="page"><div class="page-header"><div><h1 class="page-title">Inventory</h1><p class="page-subtitle">Monitor stock by SKU, warehouse and availability against reorder points.</p></div><button mat-flat-button color="primary" [disabled]="form.invalid">Post Adjustment</button></div>
      <mat-card><mat-card-content><form [formGroup]="form" class="form-grid">
        <mat-form-field appearance="outline"><mat-label>SKU</mat-label><input matInput formControlName="sku"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Warehouse</mat-label><input matInput formControlName="warehouse"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Transaction</mat-label><mat-select formControlName="transactionType"><mat-option value="RECEIPT">Receipt</mat-option><mat-option value="ISSUE">Issue</mat-option><mat-option value="ADJUSTMENT">Adjustment</mat-option></mat-select></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Quantity</mat-label><input matInput type="number" formControlName="quantity"></mat-form-field>
      </form></mat-card-content></mat-card>
      <mat-card class="table-card"><table mat-table [dataSource]="items()">
        <ng-container matColumnDef="sku"><th mat-header-cell *matHeaderCellDef>SKU</th><td mat-cell *matCellDef="let row">{{ row.sku }}</td></ng-container>
        <ng-container matColumnDef="itemName"><th mat-header-cell *matHeaderCellDef>Item</th><td mat-cell *matCellDef="let row">{{ row.itemName }}</td></ng-container>
        <ng-container matColumnDef="warehouse"><th mat-header-cell *matHeaderCellDef>Warehouse</th><td mat-cell *matCellDef="let row">{{ row.warehouse }}</td></ng-container>
        <ng-container matColumnDef="onHandQuantity"><th mat-header-cell *matHeaderCellDef>On Hand</th><td mat-cell *matCellDef="let row">{{ row.onHandQuantity }}</td></ng-container>
        <ng-container matColumnDef="availableQuantity"><th mat-header-cell *matHeaderCellDef>Available</th><td mat-cell *matCellDef="let row">{{ row.availableQuantity }}</td></ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr><tr mat-row *matRowDef="let row; columns: columns"></tr>
      </table></mat-card>
    </section>`
})
export class InventoryComponent {
  private readonly fb = inject(FormBuilder);
  readonly items = signal<InventoryItem[]>([]);
  readonly columns = ['sku', 'itemName', 'warehouse', 'onHandQuantity', 'availableQuantity'];
  readonly form = this.fb.nonNullable.group({ sku: ['', Validators.required], warehouse: ['', Validators.required], transactionType: ['ADJUSTMENT', Validators.required], quantity: [0, [Validators.required, Validators.min(0.0001)]] });
  constructor() { inject(InventoryService).list().subscribe(items => this.items.set(items)); }
}
