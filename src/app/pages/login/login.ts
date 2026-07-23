import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  imports: [FormsModule, RouterLink],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class Login {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  protected email = '';
  protected password = '';
  protected error: string | null = null;
  protected loading = false;

  protected submit(): void {
    this.error = null;
    this.loading = true;

    this.auth.login({ email: this.email.trim(), password: this.password }).subscribe({
      next: () => {
        this.loading = false;
        void this.router.navigateByUrl('/inicio');
      },
      error: (err) => {
        this.loading = false;
        this.error =
          err?.error?.message ??
          (err?.status === 403 ? 'Cuenta deshabilitada' : 'No se pudo iniciar sesion');
      },
    });
  }
}
