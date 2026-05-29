export interface LoginRequest { username: string; password: string; }
export interface AuthResponse { accessToken: string; tokenType: string; expiresAt: string; username: string; authorities: string[]; }
export interface SessionUser { username: string; authorities: string[]; expiresAt: string; }
