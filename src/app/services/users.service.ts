import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { AuthUser } from '../models/auth';

@Injectable({ providedIn: 'root' })
export class UsersService {
  private readonly http = inject(HttpClient);

  list(): Observable<{ items: AuthUser[] }> {
    return this.http.get<{ items: AuthUser[] }>('/api/users');
  }

  disable(id: number): Observable<AuthUser> {
    return this.http.post<AuthUser>(`/api/users/${id}/disable`, {});
  }

  enable(id: number): Observable<AuthUser> {
    return this.http.post<AuthUser>(`/api/users/${id}/enable`, {});
  }
}
