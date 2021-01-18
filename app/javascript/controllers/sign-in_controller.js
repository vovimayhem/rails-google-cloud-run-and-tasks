// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"
import firebase from "firebase/app"
import "firebase/auth"

export default class extends Controller {
  static targets = [ "email", "password", "output", "submit" ]

  connect() {
    this.outputTarget.textContent = 'Hello, Stimulus is Online!'
  }

  submit(event) {
    event.preventDefault()
    this.outputTarget.textContent = 'Signing you in...'

    const email = this.emailTarget.value
    const password = this.passwordTarget.value
    
    firebase.auth().signInWithEmailAndPassword(email, password)
    .then((user) => {
      debugger // TODO: Verify ID Token - see https://firebase.google.com/docs/auth/admin/verify-id-tokens
    })
    .catch((error) => {
      const errorCode = error.code;
      const errorMessage = error.message;
      this.outputTarget.textContent = `${errorMessage} (${errorCode})`
      this.submitTarget.disabled = false
    });
  }
}
