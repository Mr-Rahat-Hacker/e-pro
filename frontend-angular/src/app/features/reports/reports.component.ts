import { Component, inject, signal } from '@angular/core';
import { BaseChartDirective } from 'ng2-charts';
import { ChartConfiguration } from 'chart.js';
import { MatCardModule } from '@angular/material/card';
import { ReportKpi } from '../../core/models/procurement.model';
import { ReportsService } from './reports.service';

@Component({
  selector: 'epro-reports',
  standalone: true,
  imports: [BaseChartDirective, MatCardModule],
  template: `
    <section class="page"><div class="page-header"><div><h1 class="page-title">Reports</h1><p class="page-subtitle">Spend analytics, savings, supplier concentration and compliance reporting.</p></div></div>
      <div class="grid grid-4">@for (kpi of kpis(); track kpi.label) { <mat-card><mat-card-content><span class="label">{{ kpi.label }}</span><strong>{{ kpi.value }}</strong><small>{{ kpi.trend }}</small></mat-card-content></mat-card> }</div>
      <div class="grid grid-2 charts"><mat-card><mat-card-header><mat-card-title>Monthly Spend</mat-card-title></mat-card-header><mat-card-content><canvas baseChart [data]="monthlySpend" [options]="options" type="line"></canvas></mat-card-content></mat-card><mat-card><mat-card-header><mat-card-title>Supplier Risk</mat-card-title></mat-card-header><mat-card-content><canvas baseChart [data]="riskData" [options]="options" type="doughnut"></canvas></mat-card-content></mat-card></div>
    </section>
  `,
  styles: [`mat-card strong { display: block; font-size: 28px; margin: 8px 0; } .label, small { color: #65758b; } .charts { margin-top: 16px; }`]
})
export class ReportsComponent {
  readonly kpis = signal<ReportKpi[]>([]);
  readonly options: ChartConfiguration['options'] = { responsive: true, maintainAspectRatio: false };
  readonly monthlySpend = { labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'], datasets: [{ label: 'Spend ($M)', data: [1.6, 1.8, 2.2, 1.9, 2.4, 2.9], borderColor: '#1976d2', tension: .35 }] };
  readonly riskData = { labels: ['Low', 'Medium', 'High', 'Critical'], datasets: [{ data: [68, 21, 9, 2], backgroundColor: ['#16a34a', '#f59e0b', '#f97316', '#dc2626'] }] };
  constructor() { inject(ReportsService).kpis().subscribe(kpis => this.kpis.set(kpis)); }
}
