import '@hotwired/turbo-rails'
import 'controllers'
import 'custom/menu'
import './config/jquery'
import './products/show_products.js'
import { Turbo } from "@hotwired/turbo-rails"

document.addEventListener('DOMContentLoaded', function() {
  const showLoginPopup = document.getElementById('show-login-popup');
  const loginPopup = document.getElementById('login-popup');
  const closeModal = document.getElementById('close-modal');

  if (showLoginPopup) {
    showLoginPopup.addEventListener('click', function() {
      loginPopup.style.display = 'flex';
    });

    closeModal.addEventListener('click', function() {
      loginPopup.style.display = 'none';
    });

    window.addEventListener('click', function(event) {
      if (event.target === loginPopup) {
        loginPopup.style.display = 'none';
      }
    });
  }
});
