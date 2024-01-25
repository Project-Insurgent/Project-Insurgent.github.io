import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import fangames from '../assets/metadata/fangames.json';

@Component({
  selector: 'app-fangames-tab',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './fangames-tab.component.html',
  styleUrls: ['./fangames-tab.component.scss']
})
export class FangamesTabComponent {

}
