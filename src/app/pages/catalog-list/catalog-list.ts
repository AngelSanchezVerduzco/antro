import { Component, Input, OnInit, inject } from '@angular/core';
import { CatalogItem, CatalogService } from '../../services/catalog.service';

@Component({
  selector: 'app-catalog-list',
  templateUrl: './catalog-list.html',
  styleUrl: '../page-shared.css',
})
export class CatalogList implements OnInit {
  @Input({ required: true }) title!: string;
  @Input() lead = '';
  @Input() tipo?: string;
  @Input() categoria?: string;

  private readonly catalog = inject(CatalogService);

  protected items: CatalogItem[] = [];
  protected error: string | null = null;
  protected loading = true;

  ngOnInit(): void {
    this.catalog.list({ tipo: this.tipo, categoria: this.categoria }).subscribe({
      next: (res) => {
        this.items = res.items;
        this.loading = false;
      },
      error: (err) => {
        this.error = err?.error?.error ?? 'No se pudo cargar el catalogo';
        this.loading = false;
      },
    });
  }
}
