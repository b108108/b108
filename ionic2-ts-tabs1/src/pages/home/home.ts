import { Component } from '@angular/core';

import { NavController } from 'ionic-angular';
import { MenuPage } from '../menu/menu';

@Component({
  selector: 'page-home',
  templateUrl: 'home.html'
})
export class HomePage {

  constructor(public navCtrl: NavController) {

  }
  
  onLink(url: string) {
      window.open(url);
  }

  gotoMenu() {
      this.navCtrl.push(MenuPage);
  }

}
