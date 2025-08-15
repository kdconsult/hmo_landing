 import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitButton", "successMessage", "errorMessage"]

  connect() {
    this.setupFormValidation()
  }

  setupFormValidation() {
    // Add real-time validation feedback
    this.element.querySelectorAll('input, select').forEach(field => {
      field.addEventListener('blur', () => this.validateField(field))
      field.addEventListener('input', () => this.clearFieldError(field))
    })
  }

  validateField(field) {
    const value = field.value.trim()
    const isRequired = field.hasAttribute('required')
    
    if (isRequired && !value) {
      this.showFieldError(field, 'This field is required')
      return false
    }
    
    if (field.type === 'email' && value && !this.isValidEmail(value)) {
      this.showFieldError(field, 'Please enter a valid email address')
      return false
    }
    
    this.clearFieldError(field)
    return true
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  showFieldError(field, message) {
    // Remove existing error
    this.clearFieldError(field)
    
    // Add error styling
    field.classList.add('border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
    
    // Create and show error message
    const errorDiv = document.createElement('div')
    errorDiv.className = 'text-red-500 text-sm mt-1'
    errorDiv.textContent = message
    errorDiv.dataset.errorMessage = 'true'
    
    field.parentNode.appendChild(errorDiv)
  }

  clearFieldError(field) {
    field.classList.remove('border-red-500', 'focus:border-red-500', 'focus:ring-red-500')
    field.classList.add('border-gray-300', 'focus:border-primary', 'focus:ring-primary')
    
    // Remove error message
    const errorMessage = field.parentNode.querySelector('[data-error-message="true"]')
    if (errorMessage) {
      errorMessage.remove()
    }
  }

  async submitForm(event) {
    event.preventDefault()
    
    // Validate all fields
    const fields = this.element.querySelectorAll('input, select')
    let isValid = true
    
    fields.forEach(field => {
      if (!this.validateField(field)) {
        isValid = false
      }
    })
    
    if (!isValid) {
      return
    }
    
    // Show loading state
    this.showLoadingState()
    
    try {
      // Collect form data
      const formData = new FormData(this.element)
      const data = Object.fromEntries(formData.entries())
      
      // Simulate API call (replace with actual endpoint)
      await this.submitToAPI(data)
      
      // Show success message
      this.showSuccessMessage()
      
      // Reset form
      this.element.reset()
      
    } catch (error) {
      // Show error message
      this.showErrorMessage('Something went wrong. Please try again.')
    } finally {
      // Hide loading state
      this.hideLoadingState()
    }
  }

  async submitToAPI(data) {
    // Simulate API call delay
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    // For now, just log the data
    console.log('Waitlist signup data:', data)
    
    // TODO: Replace with actual API endpoint
    // const response = await fetch('/api/waitlist', {
    //   method: 'POST',
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: JSON.stringify(data)
    // })
    // 
    // if (!response.ok) {
    //   throw new Error('Failed to submit form')
    // }
    // 
    // return response.json()
  }

  showLoadingState() {
    const submitButton = this.element.querySelector('button[type="submit"]')
    if (submitButton) {
      submitButton.disabled = true
      submitButton.innerHTML = '<span class="inline-block animate-spin mr-2">⏳</span> Joining Waitlist...'
      submitButton.classList.add('opacity-75', 'cursor-not-allowed')
    }
  }

  hideLoadingState() {
    const submitButton = this.element.querySelector('button[type="submit"]')
    if (submitButton) {
      submitButton.disabled = false
      submitButton.innerHTML = '🚀 Join the Waitlist'
      submitButton.classList.remove('opacity-75', 'cursor-not-allowed')
    }
  }

  showSuccessMessage() {
    // Create success message
    const successDiv = document.createElement('div')
    successDiv.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-4 rounded-xl shadow-lg z-50 transform transition-all duration-300'
    successDiv.innerHTML = `
      <div class="flex items-center gap-3">
        <span class="text-2xl">🎉</span>
        <div>
          <div class="font-semibold">Welcome to the waitlist!</div>
          <div class="text-sm opacity-90">We'll notify you as soon as we launch.</div>
        </div>
      </div>
    `
    
    document.body.appendChild(successDiv)
    
    // Animate in
    setTimeout(() => {
      successDiv.classList.add('translate-x-0')
    }, 100)
    
    // Remove after 5 seconds
    setTimeout(() => {
      successDiv.classList.add('-translate-x-full', 'opacity-0')
      setTimeout(() => {
        if (successDiv.parentNode) {
          successDiv.parentNode.removeChild(successDiv)
        }
      }, 300)
    }, 5000)
  }

  showErrorMessage(message) {
    // Create error message
    const errorDiv = document.createElement('div')
    errorDiv.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-4 rounded-xl shadow-lg z-50 transform transition-all duration-300'
    errorDiv.innerHTML = `
      <div class="flex items-center gap-3">
        <span class="text-2xl">❌</span>
        <div>
          <div class="font-semibold">Oops!</div>
          <div class="text-sm opacity-90">${message}</div>
        </div>
      </div>
    `
    
    document.body.appendChild(errorDiv)
    
    // Animate in
    setTimeout(() => {
      errorDiv.classList.add('translate-x-0')
    }, 100)
    
    // Remove after 5 seconds
    setTimeout(() => {
      errorDiv.classList.add('-translate-x-full', 'opacity-0')
      setTimeout(() => {
        if (errorDiv.parentNode) {
          errorDiv.parentNode.removeChild(errorDiv)
        }
      }, 300)
    }, 5000)
  }
}