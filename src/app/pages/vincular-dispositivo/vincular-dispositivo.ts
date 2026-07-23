import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-vincular-dispositivo',
  imports: [FormsModule],
  templateUrl: './vincular-dispositivo.html',
  styleUrl: '../page-shared.css',
})
export class VincularDispositivo {
  private readonly auth = inject(AuthService);

  protected pairingCode = '';
  protected message: string | null = null;
  protected error: string | null = null;
  protected loading = false;

  protected submit(): void {
    this.message = null;
    this.error = null;
    this.loading = true;

    this.auth.confirmDevicePairing(this.pairingCode.trim()).subscribe({
      next: (user) => {
        this.loading = false;
        this.message = `Reloj vinculado a ${user.email}. Ya puedes usarlo en Flutter.`;
        this.pairingCode = '';
      },
      error: (err) => {
        this.loading = false;
        this.error = err?.error?.message ?? 'Codigo invalido o expirado';
      },
    });
  }
}
