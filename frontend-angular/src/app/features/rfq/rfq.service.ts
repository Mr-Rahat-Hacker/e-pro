import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { Rfq } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class RfqService {
  list(): Observable<Rfq[]> {
    return of([
      { id: '1', rfqNumber: 'RFQ-2026-0001', title: 'MRO Gloves RFQ', status: 'APPROVED', dueDate: '2026-06-15', invitedVendors: 5, estimatedValue: 25000 },
      { id: '2', rfqNumber: 'RFQ-2026-0002', title: 'Warehouse Scanner Devices', status: 'SUBMITTED', dueDate: '2026-06-21', invitedVendors: 3, estimatedValue: 48000 }
    ]);
  }
}
