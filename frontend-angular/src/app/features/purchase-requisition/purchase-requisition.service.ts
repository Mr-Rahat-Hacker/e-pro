import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { PageResponse } from '../../core/models/api.model';
import { ApiClientService } from '../../core/services/api-client.service';
import { PurchaseRequisition, PurchaseRequisitionCreateRequest } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class PurchaseRequisitionService {
  private readonly api = inject(ApiClientService);
  list(): Observable<PurchaseRequisition[]> { return this.api.getPage<PurchaseRequisition>('/purchase-requisitions').pipe(map((page: PageResponse<PurchaseRequisition>) => page.content)); }
  create(request: PurchaseRequisitionCreateRequest): Observable<PurchaseRequisition> { return this.api.post<PurchaseRequisition, PurchaseRequisitionCreateRequest>('/purchase-requisitions', request); }
  submit(id: string): Observable<PurchaseRequisition> { return this.api.post<PurchaseRequisition, Record<string, never>>(`/purchase-requisitions/${id}/submit`, {}); }
}
