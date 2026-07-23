import { Component } from '@angular/core';
import { CatalogList } from '../catalog-list/catalog-list';

@Component({
  selector: 'app-eventos',
  imports: [CatalogList],
  template: `<app-catalog-list
    title="Eventos"
    lead="Proximas noches y sesiones en Nexus."
    tipo="evento"
  />`,
})
export class Eventos {}
