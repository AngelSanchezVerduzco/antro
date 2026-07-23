import { Component } from '@angular/core';
import { CatalogList } from '../catalog-list/catalog-list';

@Component({
  selector: 'app-galeria',
  imports: [CatalogList],
  template: `<app-catalog-list
    title="Galeria"
    lead="Ambiente, pista y barra."
    tipo="galeria"
  />`,
})
export class Galeria {}
