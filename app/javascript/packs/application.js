// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "jquery"
import "popper.js"
import "bootstrap"
import firebase from "firebase/app"

import "controllers"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

var config = {
  apiKey: "AIzaSyBXqqLPmD_riyuycQ8-H5tZeI18l4JusCI",
  authDomain: "icalia-devops.firebaseapp.com",
};

firebase.initializeApp(config);
