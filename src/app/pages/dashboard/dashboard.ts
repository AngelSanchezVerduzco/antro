import { Component } from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';

@Component({
  selector: 'app-dashboard',
  imports: [],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.css',
})
export class Dashboard {
  protected readonly flutterSrc: SafeResourceUrl;

  constructor(sanitizer: DomSanitizer) {
    this.flutterSrc = sanitizer.bypassSecurityTrustResourceUrl('/flutter-dashboard/index.html');
  }
}
