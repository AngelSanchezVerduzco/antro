import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

export interface Reservacion {
  id: number;
  userId?: number | null;
  fullName: string;
  email: string;
  phone?: string | null;
  partySize: number;
  reservedAt: string;
  notes?: string | null;
  status: string;
  createdAt: string;
}

export interface ReservacionesResponse {
  total: number;
  items: Reservacion[];
}

@Injectable({ providedIn: 'root' })
export class ReservacionesService {
  private readonly http = inject(HttpClient);

  list(email?: string): Observable<ReservacionesResponse> {
    let params = new HttpParams();
    if (email) params = params.set('email', email);
    return this.http.get<ReservacionesResponse>('/api/reservaciones', { params });
  }

  create(payload: {
    fullName: string;
    email: string;
    phone?: string;
    partySize: number;
    reservedAt: string;
    notes?: string;
    userId?: number;
  }): Observable<Reservacion> {
    return this.http.post<Reservacion>('/api/reservaciones', payload);
  }
}
