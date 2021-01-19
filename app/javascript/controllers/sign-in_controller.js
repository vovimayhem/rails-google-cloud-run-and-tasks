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
  static targets = [ "email", "password", "output", "submit", "token", "sessionForm" ]

  connect() {
    this.outputTarget.textContent = 'Hello, Stimulus is Online!'
  }

  async submit(event) {
    event.preventDefault()
    this.outputTarget.textContent = 'Signing you in...'

    const email = this.emailTarget.value
    const password = this.passwordTarget.value

    const auth = firebase.auth()
    
    try {
      const user = await auth.signInWithEmailAndPassword(email, password)
      const idToken = await auth.currentUser.getIdToken(/* forceRefresh */ true)
      
      this.tokenTarget.value = idToken
      this.sessionFormTarget.submit()
    } catch(error) {
      const errorCode = error.code;
      const errorMessage = error.message;
      this.outputTarget.textContent = `${errorMessage} (${errorCode})`
      this.submitTarget.disabled = false

      return false
    }
  }
}
