import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "hamburger"]

  connect() {
    this.setupSmoothScrolling()
    this.addFloatingElements()
    this.setupScrollToTop()
  }

  toggleMobileMenu() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.toggle('hidden');
    }
  }

  closeMobileMenu() {
    if (this.hasMobileMenuTarget) {
      setTimeout(() => {
        this.mobileMenuTarget.classList.add('hidden');
        this.mobileMenuTarget.classList.remove('block', 'flex');
      }, 100);
    }
    if (this.hasHamburgerTarget) this.hamburgerTarget.blur();
  }

  setupSmoothScrolling() {
    // Handle smooth scrolling for navigation links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault()
        const target = document.querySelector(this.getAttribute('href'))
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          })
        }
      })
    })
  }

  // Add some interactive elements
  addFloatingElements() {
    // Add floating elements to hero section
    const hero = document.querySelector('.hero-section')
    if (hero) {
      for (let i = 0; i < 5; i++) {
        const element = document.createElement('div')
        element.className = 'absolute w-4 h-4 bg-primary/20 rounded-full animate-float'
        element.style.left = `${Math.random() * 100}%`
        element.style.top = `${Math.random() * 100}%`
        element.style.animationDelay = `${Math.random() * 2}s`
        element.style.animationDuration = `${4 + Math.random() * 4}s`
        hero.appendChild(element)
      }
    }
  }

  setupScrollToTop() {
    const scrollToTopButton = document.getElementById('scrollToTop')
    
    if (scrollToTopButton) {
      // Show/hide button based on scroll position
      window.addEventListener('scroll', () => {
        if (window.pageYOffset > 300) {
          scrollToTopButton.classList.remove('opacity-0', 'pointer-events-none')
        } else {
          scrollToTopButton.classList.add('opacity-0', 'pointer-events-none')
        }
      })
      
      // Scroll to top when clicked
      scrollToTopButton.addEventListener('click', () => {
        window.scrollTo({
          top: 0,
          behavior: 'smooth'
        })
      })
    }
  }
}
