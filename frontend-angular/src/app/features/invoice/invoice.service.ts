import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiClientService } from '../../core/services/api-client.service';
import { PageResponse } from '../../core/models/api.model';
import { Invoice } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class InvoiceService {
  private readonly api = inject(ApiClientService);
  list(): Observable<Invoice[]> { return this.api.getPage<Invoice>('/invoices').pipe(map((page: PageResponse<Invoice>) => page.content)); }
}
