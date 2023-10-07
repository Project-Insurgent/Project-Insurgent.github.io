import { Component, HostListener, ViewEncapsulation } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { MaterialModule } from "./Material.module";
import { ScriptsTabComponent } from './components/scripts/scripts-tab/scripts-tab.component';
import { SpritesTabComponent } from './components/sprites/sprites-tab/sprites-tab.component';
import { FangamesTabComponent } from './components/fangames/fangames-tab/fangames-tab.component';
//import { BrowserModule } from "@angular/platform-browser";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    MaterialModule,
    ScriptsTabComponent,
    SpritesTabComponent,
    FangamesTabComponent,
  ],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  encapsulation: ViewEncapsulation.None
})
export class AppComponent {
  title = 'somer-hub';
  readonly MIN_WIDTH_THRES: number = 550;
  public getScreenWidth: number;
  public getScreenHeight: number;
  public tabIndex: number;

  constructor() {
    this.getScreenWidth = window.innerWidth;
    this.getScreenHeight = window.innerHeight;
    this.tabIndex = 0;
  }

  @HostListener('window:resize', ['$event'])
  onWindowResize() {
    this.getScreenWidth = window.innerWidth;
    this.getScreenHeight = window.innerHeight;
  }
}
