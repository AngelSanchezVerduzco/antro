import { DatePipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Reservacion, ReservacionesService } from '../../services/reservaciones.service';

@Component({
  selector: 'app-reservaciones',
  imports: [FormsModule, DatePipe],
  templateUrl: './reservaciones.html',
  styleUrl: '../page-shared.css',
})
export class Reservaciones implements OnInit {
  private readonly api = inject(ReservacionesService);
  protected readonly auth = inject(AuthService);

  protected items: Reservacion[] = [];
  protected fullName = '';
  protected email = '';
  protected phone = '';
  protected partySize = 2;
  protected reservedAt = '';
  protected notes = '';
  protected error: string | null = null;
  protected message: string | null = null;
  protected loading = false;

  ngOnInit(): void {
    const user = this.auth.user();
    if (user) {
      this.fullName = user.fullName;
      this.email = user.email;
      this.reload(user.email);
    }
  }

  protected reload(email?: string): void {
    this.loading = true;
    this.api.list(email).subscribe({
      next: (res) => {
        this.items = res.items;
        this.loading = false;
      },
      error: (err) => {
        this.error = err?.error?.error ?? 'No se pudieron cargar reservaciones';
        this.loading = false;
      },
    });
  }

  protected submit(): void {
    this.error = null;
    this.message = null;

    const reservedAtIso = new Date(this.reservedAt).toISOString();
    this.api
      .create({
        fullName: this.fullName,
        email: this.email,
        phone: this.phone || undefined,
        partySize: this.partySize,
        reservedAt: reservedAtIso,
        notes: this.notes || undefined,
        userId: this.auth.user()?.id,
      })
      .subscribe({
        next: () => {
          this.message = 'Reservacion creada en Supabase.';
          this.reload(this.email);
        },
        error: (err) => {
          this.error = err?.error?.error ?? 'No se pudo crear la reservacion';
        },
      });
  }
}
