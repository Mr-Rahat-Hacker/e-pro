import { Injectable, computed, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { ApiClientService } from './api-client.service';
import { AuthResponse, LoginRequest, SessionUser } from '../models/auth.model';

const TOKEN_KEY = 'eproc.jwt';
const USER_KEY = 'eproc.user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(ApiClientService);
  private readonly router = inject(Router);
  private readonly userSignal = signal<SessionUser | null>(this.loadUser());
  readonly currentUser = computed(() => this.userSignal());
  readonly isAuthenticated = computed(() => !!this.userSignal() && !!this.token);

  get token(): string | null { return localStorage.getItem(TOKEN_KEY); }

  login(request: LoginRequest): Observable<AuthResponse> {
    return this.api.post<AuthResponse, LoginRequest>('/auth/login', request).pipe(
      tap(response => {
        localStorage.setItem(TOKEN_KEY, response.accessToken);
        const user: SessionUser = { username: response.username, authorities: response.authorities, expiresAt: response.expiresAt };
        localStorage.setItem(USER_KEY, JSON.stringify(user));
        this.userSignal.set(user);
      })
    );
  }

  logout(): void {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    this.userSignal.set(null);
    void this.router.navigateByUrl('/login');
  }

  hasAnyAuthority(authorities: string[]): boolean {
    const userAuthorities = this.userSignal()?.authorities ?? [];
    return authorities.some(authority => userAuthorities.includes(authority));
  }

  private loadUser(): SessionUser | null {
    const raw = localStorage.getItem(USER_KEY);
    return raw ? JSON.parse(raw) as SessionUser : null;
  }
}
