import { Component, OnDestroy, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import {
  Subject,
  Subscription,
  catchError,
  debounceTime,
  distinctUntilChanged,
  finalize,
  of,
  switchMap,
} from 'rxjs';
import { SearchHit, SearchResponse } from '../../models/search-hit';
import { SearchService } from '../../services/search.service';

interface NavItem {
  label: string;
  route: string;
  icon: 'home' | 'menu' | 'tag' | 'calendar' | 'image' | 'reservation' | 'location';
}

@Component({
  selector: 'app-app-shell',
  imports: [RouterOutlet, RouterLink, RouterLinkActive, FormsModule],
  templateUrl: './app-shell.html',
  styleUrl: './app-shell.css',
})
export class AppShell implements OnInit, OnDestroy {
  private readonly searchService = inject(SearchService);
  private readonly searchTerms$ = new Subject<string>();
  private searchSub?: Subscription;

  protected searchQuery = '';
  protected searchResults: SearchHit[] = [];
  protected searchTotal = 0;
  protected searchLoading = false;
  protected searchError: string | null = null;
  protected showResults = false;
  protected elasticsearchOnline = true;

  protected readonly navItems: NavItem[] = [
    { label: 'Inicio', route: '/inicio', icon: 'home' },
    { label: 'Carta', route: '/carta', icon: 'menu' },
    { label: 'Promociones', route: '/promociones', icon: 'tag' },
    { label: 'Eventos', route: '/eventos', icon: 'calendar' },
    { label: 'Galería', route: '/galeria', icon: 'image' },
    { label: 'Reservaciones', route: '/reservaciones', icon: 'reservation' },
    { label: 'Ubicación', route: '/ubicacion', icon: 'location' },
  ];

  ngOnInit(): void {
    this.searchService.health().subscribe((h) => {
      this.elasticsearchOnline = h.elasticsearch;
    });

    this.searchSub = this.searchTerms$
      .pipe(
        debounceTime(350),
        distinctUntilChanged(),
        switchMap((q) => {
          const trimmed = q.trim();
          if (!trimmed) {
            this.searchLoading = false;
            this.searchError = null;
            return of({ total: 0, hits: [] });
          }

          this.searchLoading = true;
          this.searchError = null;
          this.showResults = true;

          return this.searchService.search(trimmed).pipe(
            catchError(() =>
              of({
                total: 0,
                hits: [],
                error: 'Error al buscar. Revisa que Elasticsearch y la API estén activos.',
              }),
            ),
            finalize(() => {
              this.searchLoading = false;
            }),
          );
        }),
      )
      .subscribe((res: SearchResponse) => {
        this.searchResults = res.hits;
        this.searchTotal = res.total;
        this.searchError = res.error ?? null;
        if (res.error) {
          this.elasticsearchOnline = false;
        }
      });
  }

  ngOnDestroy(): void {
    this.searchSub?.unsubscribe();
  }

  protected onSearchInput(): void {
    const q = this.searchQuery;
    if (!q.trim()) {
      this.showResults = false;
      this.searchResults = [];
      this.searchTotal = 0;
      this.searchError = null;
    }
    this.searchTerms$.next(q);
  }

  protected onSearchFocus(): void {
    if (this.searchQuery.trim()) {
      this.showResults = true;
    }
  }

  protected closeResults(): void {
    this.showResults = false;
  }

  protected tipoLabel(tipo: string): string {
    const labels: Record<string, string> = {
      evento: 'Evento',
      promocion: 'Promoción',
      carta: 'Carta',
      galeria: 'Galería',
      reservacion: 'Reservación',
      ubicacion: 'Ubicación',
      pagina: 'Página',
    };
    return labels[tipo] ?? tipo;
  }
}
