import { Component } from '@angular/core';

import { NavController, NavParams } from 'ionic-angular';

@Component({
  selector: 'page-menu',
  templateUrl: 'menu.html'
})
export class MenuPage {
  selectedItem: any;
  titleMenu: string[];
  iconMenu: string[];
  items: Array<{icon: string, title: string}>;

  constructor(public navCtrl: NavController, public navParams: NavParams) {
    // If we navigated to this page, we will have an item available as a nav param
    this.selectedItem = navParams.get('item');

    // Let's populate this page with some filler content for funzies
    this.titleMenu = ['Главная', 'Меню', 'Акции', 'Доставка', 'Контакты', 'Опросы', 'О нас'];
    this.iconMenu = ['icon-home','icon-menu', 'icon-sale', 'icon-delivry', 'icon-map', 'icon-task', 'icon-about'];

    this.items = [];
    for (let i = 1; i < 7; i++) {
        this.items.push({
            icon: this.iconMenu[i],
            title: this.titleMenu[i]
        });
    }
  }

  itemTapped(event, item) {
    // That's right, we're pushing to ourselves!
    this.navCtrl.push(MenuPage, {
      item: item
    });
  }
}
