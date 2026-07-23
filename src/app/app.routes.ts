import { Routes } from '@angular/router';
import { adminGuard, authGuard } from './guards/auth.guard';
import { AppShell } from './layout/app-shell/app-shell';
import { Carta } from './pages/carta/carta';
import { Dashboard } from './pages/dashboard/dashboard';
import { Eventos } from './pages/eventos/eventos';
import { Galeria } from './pages/galeria/galeria';
import { Inicio } from './pages/inicio/inicio';
import { Login } from './pages/login/login';
import { Promociones } from './pages/promociones/promociones';
import { Register } from './pages/register/register';
import { Reservaciones } from './pages/reservaciones/reservaciones';
import { Ubicacion } from './pages/ubicacion/ubicacion';
import { Usuarios } from './pages/usuarios/usuarios';
import { VincularDispositivo } from './pages/vincular-dispositivo/vincular-dispositivo';

export const routes: Routes = [
  { path: 'login', component: Login },
  { path: 'register', component: Register },
  {
    path: '',
    component: AppShell,
    children: [
      { path: '', redirectTo: 'inicio', pathMatch: 'full' },
      { path: 'inicio', component: Inicio },
      { path: 'dashboard', component: Dashboard },
      { path: 'carta', component: Carta },
      { path: 'promociones', component: Promociones },
      { path: 'eventos', component: Eventos },
      { path: 'galeria', component: Galeria },
      { path: 'reservaciones', component: Reservaciones },
      { path: 'ubicacion', component: Ubicacion },
      {
        path: 'vincular-dispositivo',
        component: VincularDispositivo,
        canActivate: [authGuard],
      },
      {
        path: 'usuarios',
        component: Usuarios,
        canActivate: [adminGuard],
      },
    ],
  },
  { path: '**', redirectTo: 'inicio' },
];
