import { DatePipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { Promocion, PromocionesService } from '../../services/promociones.service';

@Component({
  selector: 'app-promociones',
  imports: [FormsModule, DatePipe],
  templateUrl: './promociones.html',
  styleUrl: '../page-shared.css',
})
export class Promociones implements OnInit {
  private readonly promocionesApi = inject(PromocionesService);
  protected readonly auth = inject(AuthService);

  protected items: Promocion[] = [];
  protected title = '';
  protected body = '';
  protected error: string | null = null;
  protected message: string | null = null;
  protected loading = true;
  protected saving = false;

  ngOnInit(): void {
    this.reload();
  }

  protected reload(): void {
    this.loading = true;
    this.promocionesApi.list().subscribe({
      next: (res) => {
        this.items = res.items;
        this.loading = false;
      },
      error: (err) => {
        this.error = err?.error?.error ?? 'No se pudieron cargar promociones';
        this.loading = false;
      },
    });
  }

  protected create(): void {
    this.error = null;
    this.message = null;
    this.saving = true;

    this.promocionesApi.create({ title: this.title, body: this.body }).subscribe({
      next: () => {
        this.saving = false;
        this.message = 'Promocion publicada en Supabase.';
        this.title = '';
        this.body = '';
        this.reload();
      },
      error: (err) => {
        this.saving = false;
        this.error = err?.error?.error ?? 'No se pudo crear la promocion';
      },
    });
  }

  protected remove(id: string): void {
    this.promocionesApi.delete(id).subscribe({
      next: () => this.reload(),
      error: (err) => {
        this.error = err?.error?.error ?? 'No se pudo eliminar';
      },
    });
  }
}
