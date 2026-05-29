import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { AuthResponse, LoginRequest } from '../../core/models/auth.model';
import { AuthService } from '../../core/services/auth.service';

@Injectable({ providedIn: 'root' })
export class LoginService {
  private readonly auth = inject(AuthService);
  login(request: LoginRequest): Observable<AuthResponse> { return this.auth.login(request); }
}
