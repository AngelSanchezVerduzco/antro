import { Component } from '@angular/core';
import { CatalogList } from '../catalog-list/catalog-list';

@Component({
  selector: 'app-ubicacion',
  imports: [CatalogList],
  template: `<app-catalog-list
    title="Ubicacion"
    lead="Como llegar a Nexus Nightclub."
    tipo="ubicacion"
  />`,
})
export class Ubicacion {}
