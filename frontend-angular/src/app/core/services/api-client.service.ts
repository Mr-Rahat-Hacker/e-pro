import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ApiResponse, PageResponse } from '../models/api.model';

@Injectable({ providedIn: 'root' })
export class ApiClientService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.apiBaseUrl;

  get<T>(path: string, params?: Record<string, string | number | boolean>): Observable<T> {
    return this.http.get<ApiResponse<T>>(`${this.baseUrl}${path}`, { params: this.toParams(params) }).pipe(map(response => response.data));
  }

  getPage<T>(path: string, page = 0, size = 20): Observable<PageResponse<T>> {
    return this.get<PageResponse<T>>(path, { page, size });
  }

  post<T, B>(path: string, body: B): Observable<T> {
    return this.http.post<ApiResponse<T>>(`${this.baseUrl}${path}`, body).pipe(map(response => response.data));
  }

  put<T, B>(path: string, body: B): Observable<T> {
    return this.http.put<ApiResponse<T>>(`${this.baseUrl}${path}`, body).pipe(map(response => response.data));
  }

  private toParams(params?: Record<string, string | number | boolean>): HttpParams | undefined {
    if (!params) return undefined;
    return Object.entries(params).reduce((httpParams, [key, value]) => httpParams.set(key, String(value)), new HttpParams());
  }
}
