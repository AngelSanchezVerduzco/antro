import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, of } from 'rxjs';
import { SearchResponse } from '../models/search-hit';

@Injectable({ providedIn: 'root' })
export class SearchService {
  private readonly http = inject(HttpClient);

  search(query: string): Observable<SearchResponse> {
    const params = new HttpParams().set('q', query);
    return this.http.get<SearchResponse>('/api/search', { params }).pipe(
      catchError(() =>
        of({
          total: 0,
          hits: [],
          error:
            'No se pudo conectar con el buscador. ¿Están corriendo Elasticsearch y la API (npm run api)?',
        }),
      ),
    );
  }

  health(): Observable<{ ok: boolean; elasticsearch: boolean }> {
    return this.http
      .get<{ ok: boolean; elasticsearch: boolean }>('/api/health')
      .pipe(catchError(() => of({ ok: false, elasticsearch: false })));
  }
}
