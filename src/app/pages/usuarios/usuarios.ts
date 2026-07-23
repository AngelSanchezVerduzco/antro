import { DatePipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { AuthUser } from '../../models/auth';
import { UsersService } from '../../services/users.service';

@Component({
  selector: 'app-usuarios',
  imports: [DatePipe],
  templateUrl: './usuarios.html',
  styleUrl: '../page-shared.css',
})
export class Usuarios implements OnInit {
  private readonly usersApi = inject(UsersService);
  protected readonly auth = inject(AuthService);

  protected items: AuthUser[] = [];
  protected loading = true;
  protected error: string | null = null;
  protected message: string | null = null;
  protected busyId: number | null = null;

  ngOnInit(): void {
    this.reload();
  }

  protected reload(): void {
    this.loading = true;
    this.error = null;
    this.usersApi.list().subscribe({
      next: (res) => {
        this.items = res.items;
        this.loading = false;
      },
      error: (err) => {
        this.error = err?.error?.message ?? 'No se pudieron cargar usuarios';
        this.loading = false;
      },
    });
  }

  protected toggle(user: AuthUser): void {
    this.message = null;
    this.error = null;
    this.busyId = user.id;

    const req = user.enabled ? this.usersApi.disable(user.id) : this.usersApi.enable(user.id);
    req.subscribe({
      next: (updated) => {
        this.items = this.items.map((u) => (u.id === updated.id ? updated : u));
        this.busyId = null;
        this.message = updated.enabled
          ? `${updated.email} habilitado.`
          : `${updated.email} deshabilitado (ya no puede iniciar sesion).`;
      },
      error: (err) => {
        this.busyId = null;
        this.error = err?.error?.message ?? 'No se pudo actualizar el usuario';
      },
    });
  }
}
