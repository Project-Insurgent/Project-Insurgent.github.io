import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Resource } from '../../../Utils/Resource';
import { ScriptsTabCardComponent } from '../scripts-tab-card/scripts-tab-card.component';
import scriptsJson from '../../../../assets/metadata/scripts.json';

@Component({
  selector: 'app-scripts-tab',
  standalone: true,
  imports: [CommonModule, ScriptsTabCardComponent],
  templateUrl: './scripts-tab.component.html',
  styleUrls: ['./scripts-tab.component.scss']
})
export class ScriptsTabComponent {
  @Output() scripts = new EventEmitter<Resource[]>();
  @Input() filteredList: Resource[] | undefined;

  ngOnInit(){
    this.scripts.emit(scriptsJson);
  }

  getResourceList(): void { this.scripts.emit(); }
}
