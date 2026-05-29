import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiClientService } from '../../core/services/api-client.service';
import { PageResponse } from '../../core/models/api.model';
import { PurchaseOrder } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class PurchaseOrderService {
  private readonly api = inject(ApiClientService);
  list(): Observable<PurchaseOrder[]> { return this.api.getPage<PurchaseOrder>('/purchase-orders').pipe(map((page: PageResponse<PurchaseOrder>) => page.content)); }
}
