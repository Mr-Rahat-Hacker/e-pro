import { Injectable, inject } from '@angular/core';
import { Observable, of } from 'rxjs';
import { User } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class UserManagementService {
  list(): Observable<User[]> {
    return of([
      { id: '1', employeeNo: 'EMP-0001', username: 'admin', email: 'admin@example.com', firstName: 'System', lastName: 'Administrator', department: 'IT', status: 'ACTIVE', roles: ['PROC_ADMIN'] },
      { id: '2', employeeNo: 'EMP-0002', username: 'buyer01', email: 'buyer01@example.com', firstName: 'Bianca', lastName: 'Buyer', department: 'Procurement', status: 'ACTIVE', roles: ['BUYER'] },
      { id: '3', employeeNo: 'EMP-0003', username: 'requester01', email: 'requester01@example.com', firstName: 'Ravi', lastName: 'Requester', department: 'Operations', status: 'ACTIVE', roles: ['REQUESTER'] }
    ]);
  }
}
