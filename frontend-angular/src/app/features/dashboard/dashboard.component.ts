import { Component, inject, signal } from '@angular/core';
import { BaseChartDirective } from 'ng2-charts';
import { ChartConfiguration } from 'chart.js';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { ReportKpi } from '../../core/models/procurement.model';
import { DashboardService } from './dashboard.service';

@Component({
  selector: 'epro-dashboard',
  standalone: true,
  imports: [BaseChartDirective, MatCardModule, MatIconModule],
  template: `
    <section class="page">
      <div class="page-header"><div><h1 class="page-title">Executive Dashboard</h1><p class="page-subtitle">Real-time procurement KPIs, supplier risk, spend and invoice performance.</p></div></div>
      <div class="grid grid-4">
        @for (kpi of kpis(); track kpi.label) {
          <mat-card><mat-card-content><div class="kpi"><mat-icon>{{ kpi.icon }}</mat-icon><div><span>{{ kpi.label }}</span><strong>{{ kpi.value }}</strong><small>{{ kpi.trend }}</small></div></div></mat-card-content></mat-card>
        }
      </div>
      <div class="grid grid-2 charts">
        <mat-card><mat-card-header><mat-card-title>Spend by Category</mat-card-title></mat-card-header><mat-card-content><canvas baseChart [data]="spendData" [options]="chartOptions" type="bar"></canvas></mat-card-content></mat-card>
        <mat-card><mat-card-header><mat-card-title>Procurement Pipeline</mat-card-title></mat-card-header><mat-card-content><canvas baseChart [data]="pipelineData" [options]="chartOptions" type="line"></canvas></mat-card-content></mat-card>
      </div>
    </section>
  `,
  styles: [`
    .kpi { display: flex; gap: 16px; align-items: center; }
    .kpi mat-icon { color: #0b72d0; background: #e8f2ff; border-radius: 14px; padding: 10px; width: 44px; height: 44px; }
    .kpi span, .kpi small { color: #65758b; display: block; }
    .kpi strong { display: block; font-size: 26px; margin: 4px 0; }
    .charts { margin-top: 16px; }
  `]
})
export class DashboardComponent {
  readonly kpis = signal<Array<ReportKpi & { icon: string }>>([]);
  readonly chartOptions: ChartConfiguration['options'] = { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: true } } };
  readonly spendData = { labels: ['MRO', 'IT', 'Facilities', 'Logistics', 'Services'], datasets: [{ label: 'Spend ($K)', data: [820, 640, 520, 410, 760], backgroundColor: '#1976d2' }] };
  readonly pipelineData = { labels: ['PR', 'RFQ', 'PO', 'GRN', 'Invoice'], datasets: [{ label: 'Documents', data: [184, 52, 133, 96, 78], borderColor: '#0f766e', tension: .35 }] };
  constructor() { inject(DashboardService).kpis().subscribe(kpis => this.kpis.set(kpis)); }
}
