import { CurrencyPipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { Rfq } from '../../core/models/procurement.model';
import { RfqService } from './rfq.service';

@Component({
  selector: 'epro-rfq',
  standalone: true,
  imports: [CurrencyPipe, ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatTableModule],
  template: `
    <section class="page"><div class="page-header"><div><h1 class="page-title">RFQ</h1><p class="page-subtitle">Create sourcing events, invite vendors and compare commercial responses.</p></div><button mat-flat-button color="primary" [disabled]="form.invalid">Create RFQ</button></div>
      <mat-card><mat-card-content><form [formGroup]="form" class="form-grid">
        <mat-form-field appearance="outline"><mat-label>RFQ Number</mat-label><input matInput formControlName="rfqNumber"><mat-error>Required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Title</mat-label><input matInput formControlName="title"><mat-error>Required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Due Date</mat-label><input matInput type="date" formControlName="dueDate"><mat-error>Required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Currency</mat-label><mat-select formControlName="currency"><mat-option value="USD">USD</mat-option><mat-option value="EUR">EUR</mat-option></mat-select></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Estimated Value</mat-label><input matInput type="number" formControlName="estimatedValue"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Vendor Emails</mat-label><input matInput formControlName="vendorEmails" placeholder="supplier@example.com"></mat-form-field>
      </form></mat-card-content></mat-card>
      <mat-card class="table-card"><table mat-table [dataSource]="rfqs()">
        <ng-container matColumnDef="rfqNumber"><th mat-header-cell *matHeaderCellDef>RFQ</th><td mat-cell *matCellDef="let row">{{ row.rfqNumber }}</td></ng-container>
        <ng-container matColumnDef="title"><th mat-header-cell *matHeaderCellDef>Title</th><td mat-cell *matCellDef="let row">{{ row.title }}</td></ng-container>
        <ng-container matColumnDef="status"><th mat-header-cell *matHeaderCellDef>Status</th><td mat-cell *matCellDef="let row"><span class="status-chip">{{ row.status }}</span></td></ng-container>
        <ng-container matColumnDef="invitedVendors"><th mat-header-cell *matHeaderCellDef>Invited</th><td mat-cell *matCellDef="let row">{{ row.invitedVendors }}</td></ng-container>
        <ng-container matColumnDef="estimatedValue"><th mat-header-cell *matHeaderCellDef>Value</th><td mat-cell *matCellDef="let row">{{ row.estimatedValue | currency }}</td></ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr><tr mat-row *matRowDef="let row; columns: columns"></tr>
      </table></mat-card>
    </section>`
})
export class RfqComponent {
  private readonly fb = inject(FormBuilder);
  readonly rfqs = signal<Rfq[]>([]);
  readonly columns = ['rfqNumber', 'title', 'status', 'invitedVendors', 'estimatedValue'];
  readonly form = this.fb.nonNullable.group({ rfqNumber: ['', Validators.required], title: ['', Validators.required], dueDate: ['', Validators.required], currency: ['USD', Validators.required], estimatedValue: [0, Validators.min(0)], vendorEmails: ['', Validators.email] });
  constructor() { inject(RfqService).list().subscribe(rfqs => this.rfqs.set(rfqs)); }
}
