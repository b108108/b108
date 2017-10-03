import { Component } from '@angular/core';
import { ViewChild } from '@angular/core';
import { Navbar } from 'ionic-angular';

import { NavController } from 'ionic-angular';

@Component({
  selector: 'page-about',
  templateUrl: 'about.html'
})
export class AboutPage {

  constructor(public navCtrl: NavController) {

  }

  goBack() {
      this.navCtrl.pop();
  }
}
