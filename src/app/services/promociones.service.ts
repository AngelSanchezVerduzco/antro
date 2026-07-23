import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

export interface Promocion {
  id: string;
  type: string;
  title: string;
  body: string;
  imageUrl: string;
  deepLink: string;
  expiresAt: string;
  createdAt: string;
}

export interface PromocionesResponse {
  total: number;
  items: Promocion[];
}

@Injectable({ providedIn: 'root' })
export class PromocionesService {
  private readonly http = inject(HttpClient);

  list(): Observable<PromocionesResponse> {
    return this.http.get<PromocionesResponse>('/api/promociones');
  }

  latest(): Observable<Promocion> {
    return this.http.get<Promocion>('/api/promociones/latest');
  }

  create(payload: {
    title: string;
    body: string;
    imageUrl?: string;
    deepLink?: string;
    expiresAt?: string;
  }): Observable<Promocion> {
    return this.http.post<Promocion>('/api/promociones', payload);
  }

  delete(id: string): Observable<{ ok: boolean }> {
    return this.http.delete<{ ok: boolean }>(`/api/promociones/${id}`);
  }
}
