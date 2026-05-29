import { CanActivateChildFn, CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

const evaluateAuth = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (auth.isAuthenticated()) return true;
  return router.createUrlTree(['/login']);
};

export const authGuard: CanActivateFn = () => evaluateAuth();
export const authChildGuard: CanActivateChildFn = () => evaluateAuth();
