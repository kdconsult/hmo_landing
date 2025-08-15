import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu"]

  connect() {
    this.setupSmoothScrolling()
    this.setupMobileMenu()
    this.setupCountdownTimer()
    this.addFloatingElements()
    this.setupScrollToTop()
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

  setupMobileMenu() {
    const mobileMenuButton = document.querySelector('[aria-label="Toggle mobile menu"]')
    const mobileMenu = document.querySelector('.mobile-menu')
    
    if (mobileMenuButton && mobileMenu) {
      mobileMenuButton.addEventListener('click', () => {
        mobileMenu.classList.toggle('hidden')
      })
    }
  }

  setupCountdownTimer() {
    // Set countdown to 3 days from now
    const endDate = new Date()
    endDate.setDate(endDate.getDate() + 3)
    
    const timer = setInterval(() => {
      const now = new Date().getTime()
      const distance = endDate.getTime() - now
      
      if (distance < 0) {
        clearInterval(timer)
        document.getElementById('days').textContent = '00'
        document.getElementById('hours').textContent = '00'
        document.getElementById('minutes').textContent = '00'
        return
      }
      
      const days = Math.floor(distance / (1000 * 60 * 60 * 24))
      const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
      const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
      
      document.getElementById('days').textContent = days.toString().padStart(2, '0')
      document.getElementById('hours').textContent = hours.toString().padStart(2, '0')
      document.getElementById('minutes').textContent = minutes.toString().padStart(2, '0')
    }, 1000)
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
