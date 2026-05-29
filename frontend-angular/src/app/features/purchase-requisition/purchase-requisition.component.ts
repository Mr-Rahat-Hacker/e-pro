import { CurrencyPipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { FormArray, FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';
import { PurchaseRequisition } from '../../core/models/procurement.model';
import { PurchaseRequisitionService } from './purchase-requisition.service';

@Component({
  selector: 'epro-purchase-requisition',
  standalone: true,
  imports: [CurrencyPipe, ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatIconModule, MatInputModule, MatTableModule],
  template: `
    <section class="page"><div class="page-header"><div><h1 class="page-title">Purchase Requisition</h1><p class="page-subtitle">Create demand requests with line-level validation and approval submission.</p></div><button mat-flat-button color="primary" (click)="create()" [disabled]="form.invalid">Create PR</button></div>
      <mat-card><mat-card-content><form [formGroup]="form" class="form-grid">
        <mat-form-field appearance="outline"><mat-label>PR Number</mat-label><input matInput formControlName="prNumber"><mat-error>Required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Requester User ID</mat-label><input matInput formControlName="requesterUserId"><mat-error>UUID required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Department</mat-label><input matInput formControlName="department"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Cost Center</mat-label><input matInput formControlName="costCenter"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Currency</mat-label><input matInput formControlName="currencyCode" maxlength="3"></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Required By</mat-label><input matInput type="date" formControlName="requiredByDate"></mat-form-field>
      </form>
      <div formArrayName="lines" class="lines">
        @for (line of lineGroups; track $index; let i = $index) {
          <div class="line" [formGroup]="line">
            <mat-form-field appearance="outline"><mat-label>Description</mat-label><input matInput formControlName="description"></mat-form-field>
            <mat-form-field appearance="outline"><mat-label>Qty</mat-label><input matInput type="number" formControlName="quantity"></mat-form-field>
            <mat-form-field appearance="outline"><mat-label>UOM</mat-label><input matInput formControlName="uom"></mat-form-field>
            <mat-form-field appearance="outline"><mat-label>Unit Price</mat-label><input matInput type="number" formControlName="estimatedUnitPrice"></mat-form-field>
            <button mat-icon-button color="warn" (click)="removeLine(i)" [disabled]="lines.length === 1"><mat-icon>delete</mat-icon></button>
          </div>
        }
      </div>
      <button mat-stroked-button (click)="addLine()"><mat-icon>add</mat-icon> Add Line</button>
      </mat-card-content></mat-card>
      <mat-card class="table-card"><table mat-table [dataSource]="requisitions()">
        <ng-container matColumnDef="prNumber"><th mat-header-cell *matHeaderCellDef>PR</th><td mat-cell *matCellDef="let row">{{ row.prNumber }}</td></ng-container>
        <ng-container matColumnDef="status"><th mat-header-cell *matHeaderCellDef>Status</th><td mat-cell *matCellDef="let row"><span class="status-chip">{{ row.status }}</span></td></ng-container>
        <ng-container matColumnDef="totalAmount"><th mat-header-cell *matHeaderCellDef>Total</th><td mat-cell *matCellDef="let row">{{ row.totalAmount | currency:row.currencyCode }}</td></ng-container>
        <ng-container matColumnDef="actions"><th mat-header-cell *matHeaderCellDef>Actions</th><td mat-cell *matCellDef="let row"><button mat-button (click)="submit(row)">Submit</button></td></ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr><tr mat-row *matRowDef="let row; columns: columns"></tr>
      </table></mat-card>
    </section>
  `,
  styles: [`.lines { margin: 16px 0; display: grid; gap: 12px; } .line { display: grid; grid-template-columns: 2fr 1fr 1fr 1fr auto; gap: 12px; align-items: center; } @media (max-width: 900px) { .line { grid-template-columns: 1fr; } }`]
})
export class PurchaseRequisitionComponent {
  private readonly service = inject(PurchaseRequisitionService);
  private readonly fb = inject(FormBuilder);
  readonly requisitions = signal<PurchaseRequisition[]>([]);
  readonly columns = ['prNumber', 'status', 'totalAmount', 'actions'];
  readonly form = this.fb.nonNullable.group({
    prNumber: ['', Validators.required], requesterUserId: ['', [Validators.required, Validators.pattern('[0-9a-fA-F-]{36}')]], department: [''], costCenter: [''], requiredByDate: [''], currencyCode: ['USD', [Validators.required, Validators.pattern('[A-Z]{3}')]], businessJustification: [''],
    lines: this.fb.array([this.createLineGroup()])
  });
  get lines(): FormArray { return this.form.controls.lines; }
  get lineGroups(): FormGroup[] { return this.lines.controls as FormGroup[]; }
  constructor() { this.load(); }
  addLine(): void { this.lines.push(this.createLineGroup()); }
  removeLine(index: number): void { this.lines.removeAt(index); }
  create(): void { if (this.form.invalid) return; this.service.create(this.form.getRawValue()).subscribe(pr => this.requisitions.update(items => [pr, ...items])); }
  submit(pr: PurchaseRequisition): void { this.service.submit(pr.id).subscribe(updated => this.requisitions.update(items => items.map(item => item.id === updated.id ? updated : item))); }
  private load(): void { this.service.list().subscribe({ next: prs => this.requisitions.set(prs), error: () => this.requisitions.set([]) }); }
  private createLineGroup() { return this.fb.nonNullable.group({ itemId: [''], description: ['', Validators.required], quantity: [1, [Validators.required, Validators.min(0.0001)]], uom: ['EA', Validators.required], estimatedUnitPrice: [0, [Validators.required, Validators.min(0)]], requiredByDate: [''] }); }
}
