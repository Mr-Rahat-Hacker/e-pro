import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { LoginService } from './login.service';

@Component({
  selector: 'epro-login',
  standalone: true,
  imports: [ReactiveFormsModule, MatButtonModule, MatCardModule, MatFormFieldModule, MatIconModule, MatInputModule, MatProgressSpinnerModule],
  template: `
    <section class="login-page">
      <div class="hero">
        <div class="badge"><mat-icon>verified</mat-icon> Enterprise Source-to-Pay</div>
        <h1>Govern spend, suppliers and procurement operations.</h1>
        <p>JWT-secured Angular 20 frontend for SAP MM / Coupa-class procurement workflows.</p>
      </div>
      <mat-card class="login-card">
        <mat-card-header>
          <mat-card-title>Sign in</mat-card-title>
          <mat-card-subtitle>Use your enterprise credentials</mat-card-subtitle>
        </mat-card-header>
        <mat-card-content>
          <form [formGroup]="form" (ngSubmit)="login()" class="login-form">
            <mat-form-field appearance="outline" class="full-width">
              <mat-label>Username</mat-label>
              <input matInput formControlName="username" autocomplete="username">
              <mat-error>Username is required</mat-error>
            </mat-form-field>
            <mat-form-field appearance="outline" class="full-width">
              <mat-label>Password</mat-label>
              <input matInput type="password" formControlName="password" autocomplete="current-password">
              <mat-error>Password is required</mat-error>
            </mat-form-field>
            @if (error()) { <p class="error">{{ error() }}</p> }
            <button mat-flat-button color="primary" class="full-width" [disabled]="form.invalid || loading()">
              @if (loading()) { <mat-spinner diameter="20" /> } @else { <span>Login</span> }
            </button>
          </form>
        </mat-card-content>
      </mat-card>
    </section>
  `,
  styles: [`
    .login-page { min-height: 100vh; display: grid; grid-template-columns: 1.2fr .8fr; align-items: center; gap: 48px; padding: 48px; background: linear-gradient(135deg, #0b1220, #184e77); }
    .hero { color: white; max-width: 760px; }
    .hero h1 { font-size: clamp(36px, 6vw, 72px); line-height: 1; margin: 24px 0; }
    .hero p { font-size: 20px; color: #dbeafe; }
    .badge { display: inline-flex; align-items: center; gap: 8px; background: rgba(255,255,255,.12); padding: 10px 14px; border-radius: 999px; }
    .login-card { width: min(460px, 100%); justify-self: center; padding: 18px; border-radius: 24px; }
    .login-form { display: grid; gap: 12px; margin-top: 18px; }
    .error { color: #b42318; font-weight: 600; }
    button mat-spinner { display: inline-block; }
    @media (max-width: 900px) { .login-page { grid-template-columns: 1fr; padding: 24px; } .hero { text-align: center; } }
  `]
})
export class LoginComponent {
  private readonly fb = inject(FormBuilder);
  private readonly loginService = inject(LoginService);
  private readonly router = inject(Router);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly form = this.fb.nonNullable.group({
    username: ['', Validators.required],
    password: ['', Validators.required]
  });

  login(): void {
    if (this.form.invalid) return;
    this.loading.set(true);
    this.error.set(null);
    this.loginService.login(this.form.getRawValue()).subscribe({
      next: () => void this.router.navigateByUrl('/dashboard'),
      error: () => { this.error.set('Unable to authenticate. Verify username and password.'); this.loading.set(false); },
      complete: () => this.loading.set(false)
    });
  }
}
