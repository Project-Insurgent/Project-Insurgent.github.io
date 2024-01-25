import { Component, HostListener, ViewEncapsulation, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { MaterialModule } from "./Material.module";
import { ScriptsTabComponent } from './components/scripts/scripts-tab/scripts-tab.component';
import { SpritesTabComponent } from './components/sprites/sprites-tab/sprites-tab.component';
import { FangamesTabComponent } from './components/fangames/fangames-tab/fangames-tab.component';
import { Resource } from './Utils/Resource';

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
  public filteredList:  Resource[] = [];

  @ViewChild('searchBar') searchBar!: ElementRef;

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

  onClickFilters(): void {}

  onInputChange(): void {
    const searchValue = this.searchBar.nativeElement.value;
    if (!searchValue) {
      this.filteredList = [];
      return;
    }
  
    this.filteredList = this.filteredList.filter(r => this.filterResource(r,searchValue.toLowerCase()));
    console.log(this.filteredList);
  }

  filterResource(r: Resource, str: string): boolean {
    var searchDeps = false;
    r?.deps?.forEach(dep => searchDeps = searchDeps || dep.includes(str));

    return  r?.title?.includes(str) || searchDeps
  }

  getResourceList(scripts: Resource[]): void {
    this.filteredList = scripts;
  }
}
