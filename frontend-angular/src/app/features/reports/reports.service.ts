import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { ReportKpi } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class ReportsService {
  kpis(): Observable<ReportKpi[]> {
    return of([
      { label: 'Managed Spend', value: '$12.8M', trend: '+14%' },
      { label: 'PO Compliance', value: '96.4%', trend: '+2.1%' },
      { label: 'Cycle Time', value: '3.8 days', trend: '-18%' },
      { label: 'Invoice Match Rate', value: '91.7%', trend: '+4.5%' }
    ]);
  }
}
