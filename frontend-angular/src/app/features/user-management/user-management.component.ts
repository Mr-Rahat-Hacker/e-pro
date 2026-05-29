import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { User } from '../../core/models/procurement.model';
import { UserManagementService } from './user-management.service';

@Component({
  selector: 'epro-user-management',
  standalone: true,
  imports: [ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatTableModule],
  template: `
    <section class="page">
      <div class="page-header"><div><h1 class="page-title">User Management</h1><p class="page-subtitle">Manage employees, departments, RBAC role assignments and access status.</p></div><button mat-flat-button color="primary" [disabled]="form.invalid">Invite User</button></div>
      <mat-card><mat-card-content><form [formGroup]="form" class="form-grid">
        <mat-form-field appearance="outline"><mat-label>Employee No</mat-label><input matInput formControlName="employeeNo"><mat-error>Required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Email</mat-label><input matInput formControlName="email"><mat-error>Valid email required</mat-error></mat-form-field>
        <mat-form-field appearance="outline"><mat-label>Role</mat-label><mat-select formControlName="role"><mat-option value="REQUESTER">Requester</mat-option><mat-option value="BUYER">Buyer</mat-option><mat-option value="APPROVER">Approver</mat-option><mat-option value="PROC_ADMIN">Proc Admin</mat-option></mat-select></mat-form-field>
      </form></mat-card-content></mat-card>
      <mat-card class="table-card"><table mat-table [dataSource]="users()">
        <ng-container matColumnDef="employeeNo"><th mat-header-cell *matHeaderCellDef>Employee</th><td mat-cell *matCellDef="let row">{{ row.employeeNo }}</td></ng-container>
        <ng-container matColumnDef="name"><th mat-header-cell *matHeaderCellDef>Name</th><td mat-cell *matCellDef="let row">{{ row.firstName }} {{ row.lastName }}</td></ng-container>
        <ng-container matColumnDef="email"><th mat-header-cell *matHeaderCellDef>Email</th><td mat-cell *matCellDef="let row">{{ row.email }}</td></ng-container>
        <ng-container matColumnDef="roles"><th mat-header-cell *matHeaderCellDef>Roles</th><td mat-cell *matCellDef="let row">{{ row.roles.join(', ') }}</td></ng-container>
        <ng-container matColumnDef="status"><th mat-header-cell *matHeaderCellDef>Status</th><td mat-cell *matCellDef="let row"><span class="status-chip">{{ row.status }}</span></td></ng-container>
        <tr mat-header-row *matHeaderRowDef="columns"></tr><tr mat-row *matRowDef="let row; columns: columns"></tr>
      </table></mat-card>
    </section>
  `
})
export class UserManagementComponent {
  private readonly fb = inject(FormBuilder);
  readonly users = signal<User[]>([]);
  readonly columns = ['employeeNo', 'name', 'email', 'roles', 'status'];
  readonly form = this.fb.nonNullable.group({ employeeNo: ['', Validators.required], email: ['', [Validators.required, Validators.email]], role: ['REQUESTER', Validators.required] });
  constructor() { inject(UserManagementService).list().subscribe(users => this.users.set(users)); }
}
