import { Component, OnInit, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CatalogItem, CatalogService } from '../../services/catalog.service';
import { Promocion, PromocionesService } from '../../services/promociones.service';

export interface EventoCard {
  fecha: string;
  titulo: string;
  generos: string;
  hora: string;
  lugar: string;
}

@Component({
  selector: 'app-inicio',
  imports: [RouterLink],
  templateUrl: './inicio.html',
  styleUrl: './inicio.css',
})
export class Inicio implements OnInit {
  private readonly catalog = inject(CatalogService);
  private readonly promociones = inject(PromocionesService);

  protected eventos: EventoCard[] = [];
  protected galeriaItems: CatalogItem[] = [];
  protected promo: Promocion | null = null;

  protected readonly carouselSlides = [0, 1, 2, 3];
  protected activeSlide = 0;

  ngOnInit(): void {
    this.catalog.list({ tipo: 'evento' }).subscribe({
      next: (res) => {
        this.eventos = res.items.slice(0, 6).map((item) => ({
          fecha: item.categoria.toUpperCase(),
          titulo: item.titulo,
          generos: item.tags?.slice(0, 3).join(' · ') || item.descripcion.slice(0, 40),
          hora: 'Noche',
          lugar: 'NEXUS',
        }));
      },
    });

    this.catalog.list({ tipo: 'galeria' }).subscribe({
      next: (res) => {
        this.galeriaItems = res.items;
      },
    });

    this.promociones.latest().subscribe({
      next: (promo) => {
        this.promo = promo;
      },
      error: () => {
        this.promo = null;
      },
    });
  }
}
