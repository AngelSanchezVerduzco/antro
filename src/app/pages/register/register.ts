import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { UserRole } from '../../models/auth';

@Component({
  selector: 'app-register',
  imports: [FormsModule, RouterLink],
  templateUrl: './register.html',
  styleUrl: '../login/login.css',
})
export class Register {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  protected fullName = '';
  protected email = '';
  protected password = '';
  protected role: UserRole = 'USER';
  protected error: string | null = null;
  protected loading = false;

  protected submit(): void {
    this.error = null;
    this.loading = true;

    this.auth
      .register({
        fullName: this.fullName.trim(),
        email: this.email.trim(),
        password: this.password,
        role: this.role,
      })
      .subscribe({
        next: () => {
          this.loading = false;
          void this.router.navigateByUrl('/inicio');
        },
        error: (err) => {
          this.loading = false;
          this.error = err?.error?.message ?? 'No se pudo registrar';
        },
      });
  }
}
