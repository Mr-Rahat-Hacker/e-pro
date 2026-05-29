import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiClientService } from '../../core/services/api-client.service';
import { PageResponse } from '../../core/models/api.model';
import { Vendor, VendorCreateRequest } from '../../core/models/procurement.model';

@Injectable({ providedIn: 'root' })
export class VendorManagementService {
  private readonly api = inject(ApiClientService);
  list(): Observable<Vendor[]> { return this.api.getPage<Vendor>('/vendors').pipe(map((page: PageResponse<Vendor>) => page.content)); }
  create(request: VendorCreateRequest): Observable<Vendor> { return this.api.post<Vendor, VendorCreateRequest>('/vendors', request); }
}
