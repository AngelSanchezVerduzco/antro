import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

export interface CatalogItem {
  id: string;
  tipo: string;
  titulo: string;
  descripcion: string;
  categoria: string;
  ruta: string;
  tags: string[];
  createdAt?: string;
}

export interface CatalogResponse {
  total: number;
  items: CatalogItem[];
}

@Injectable({ providedIn: 'root' })
export class CatalogService {
  private readonly http = inject(HttpClient);

  list(filters?: { tipo?: string; categoria?: string }): Observable<CatalogResponse> {
    let params = new HttpParams();
    if (filters?.tipo) params = params.set('tipo', filters.tipo);
    if (filters?.categoria) params = params.set('categoria', filters.categoria);
    return this.http.get<CatalogResponse>('/api/catalog', { params });
  }
}
