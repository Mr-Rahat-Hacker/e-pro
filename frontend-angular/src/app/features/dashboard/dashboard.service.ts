import { Injectable } from '@angular/core';
import { Observable, of } from 'rxjs';
import { ReportKpi } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class DashboardService {
  kpis(): Observable<Array<ReportKpi & { icon: string }>> {
    return of([
      { label: 'Managed Spend', value: '$12.8M', trend: '+14% YoY', icon: 'paid' },
      { label: 'Open PRs', value: 184, trend: '32 need approval', icon: 'assignment' },
      { label: 'PO Compliance', value: '96.4%', trend: '+2.1%', icon: 'verified' },
      { label: 'Invoice Match', value: '91.7%', trend: '8 exceptions', icon: 'rule' }
    ]);
  }
}
