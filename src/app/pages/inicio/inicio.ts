import { Component } from '@angular/core';

export interface Evento {
  fecha: string;
  titulo: string;
  generos: string;
  hora: string;
  lugar: string;
}

@Component({
  selector: 'app-inicio',
  imports: [],
  templateUrl: './inicio.html',
  styleUrl: './inicio.css',
})
export class Inicio {
  protected readonly eventos: Evento[] = [
    {
      fecha: 'VIERNES 31 MAY',
      titulo: 'NEON PARTY',
      generos: 'EDM · House · Tech',
      hora: '10:00 PM',
      lugar: 'NEXUS',
    },
    {
      fecha: 'SÁBADO 1 JUN',
      titulo: 'BASS NIGHT',
      generos: 'Drum & Bass · Dubstep',
      hora: '11:00 PM',
      lugar: 'NEXUS',
    },
    {
      fecha: 'DOMINGO 2 JUN',
      titulo: 'SUNSET SESSIONS',
      generos: 'Deep House · Chill',
      hora: '6:00 PM',
      lugar: 'ROOFTOP NEXUS',
    },
  ];

  protected readonly galeriaPlaceholders = Array.from({ length: 6 }, (_, i) => i + 1);

  protected readonly carouselSlides = [0, 1, 2, 3];
  protected activeSlide = 0;
}
