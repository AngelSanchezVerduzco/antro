import { Routes } from '@angular/router';
import { AppShell } from './layout/app-shell/app-shell';
import { Inicio } from './pages/inicio/inicio';

export const routes: Routes = [
  {
    path: '',
    component: AppShell,
    children: [
      { path: '', redirectTo: 'inicio', pathMatch: 'full' },
      { path: 'inicio', component: Inicio },
    ],
  },
  { path: '**', redirectTo: 'inicio' },
];
