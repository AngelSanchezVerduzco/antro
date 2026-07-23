import { Component } from '@angular/core';
import { CatalogList } from '../catalog-list/catalog-list';

@Component({
  selector: 'app-carta',
  imports: [CatalogList],
  template: `<app-catalog-list
    title="Carta"
    lead="Bebidas y especialidades de Nexus desde Supabase."
    categoria="carta"
  />`,
})
export class Carta {}
