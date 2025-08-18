import { Controller } from "@hotwired/stimulus"

const MAX_SPOTS = 100;
const COUPON_CODE = "EARLY50";

let spotsRemaining = MAX_SPOTS;
let joinedToday = 0;
let currentReferralCode = null; // Store the code for the current session
let leads = [];
let currentIdempotencyKey = null;

function generateIdempotencyKey() {
  if (window.crypto && window.crypto.randomUUID) {
    return window.crypto.randomUUID();
  }
  return 'idemp-' + Math.random().toString(36).slice(2) + Date.now();
}

function isToday(dateString) {
  const d = new Date(dateString);
  const now = new Date();
  return d.getFullYear() === now.getFullYear() &&
         d.getMonth() === now.getMonth() &&
         d.getDate() === now.getDate();
}

export default class extends Controller {
  async connect() {
    this.form = document.getElementById("waitlist-form");
    this.successDiv = document.getElementById("waitlist-success");
    this.errorDiv = document.getElementById("waitlist-error");
    this.fomoDiv = document.getElementById("fomo-microcopy");
    this.heroSpots = document.getElementById("spots-remaining");
    this.formSpots = document.getElementById("spots-remaining-form");
    this.progressBar = document.getElementById("spots-progress");
    this.heroJoined = document.getElementById("joined-today");
    this.spotsMessage = document.getElementById("spots-message");

    // Get slug from data attribute or global variable
    this.slug = this.form?.dataset.slug || window.landingPageSlug;
    await this.fetchLeadsAndUpdateState();
    this.updateSpotsUI();
    this.heroJoined.textContent = joinedToday;
    this.setupFormValidation();
  }

  async fetchLeadsAndUpdateState() {
    if (!this.slug) return;
    try {
      const res = await fetch(`/api/landing_pages/${this.slug}/leads`);
      if (!res.ok) throw new Error("Failed to fetch leads");
      leads = await res.json();
      spotsRemaining = MAX_SPOTS - leads.length;
      joinedToday = leads.filter(l => isToday(l.created_at)).length;
    } catch (e) {
      spotsRemaining = MAX_SPOTS;
      joinedToday = 0;
    }
  }

  setupFormValidation() {
    this.form.querySelectorAll('input, select').forEach(field => {
      field.addEventListener('blur', () => this.validateField(field))
      field.addEventListener('input', () => this.clearFieldError(field))
    })
  }

  validateField(field) {
    const value = field.value.trim();
    const isRequired = field.hasAttribute('required');
    if (isRequired && !value) {
      this.showFieldError(field, 'This field is required');
      return false;
    }
    if (field.type === 'email' && value && !this.isValidEmail(value)) {
      this.showFieldError(field, 'Please enter a valid email address');
      return false;
    }
    if (field.type === 'tel' && value && !this.isValidPhone(value)) {
      this.showFieldError(field, 'Please enter a valid phone number');
      return false;
    }
    this.clearFieldError(field);
    return true;
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  isValidPhone(phone) {
    // Accepts numbers, spaces, dashes, parentheses, plus
    const phoneRegex = /^[0-9\-\+\s\(\)]{7,}$/;
    return phoneRegex.test(phone);
  }

  showFieldError(field, message) {
    this.clearFieldError(field);
    field.classList.add('border-red-500', 'focus:border-red-500', 'focus:ring-red-500');
    const errorDiv = document.createElement('div');
    errorDiv.className = 'text-red-500 text-sm mt-1';
    errorDiv.textContent = message;
    errorDiv.dataset.errorMessage = 'true';
    field.parentNode.appendChild(errorDiv);
  }

  clearFieldError(field) {
    field.classList.remove('border-red-500', 'focus:border-red-500', 'focus:ring-red-500');
    field.classList.add('border-gray-300', 'focus:border-primary', 'focus:ring-primary');
    const errorMessage = field.parentNode.querySelector('[data-error-message="true"]');
    if (errorMessage) errorMessage.remove();
  }

  updateSpotsUI() {
    const spotWord = spotsRemaining === 1 ? 'spot' : 'spots';
    if (this.heroSpots) this.heroSpots.textContent = spotsRemaining;
    if (this.formSpots) this.formSpots.textContent = spotsRemaining;
    const formWord = document.getElementById('spots-remaining-form-word');
    if (formWord) formWord.textContent = spotWord;
    if (this.progressBar) {
      const percent = Math.max(0, Math.min(100, (spotsRemaining / MAX_SPOTS) * 100));
      this.progressBar.style.width = percent + "%";
      // Remove all gradient color classes first
      this.progressBar.classList.remove('bg-primary', 'bg-yellow-400', 'bg-red-500', 'from-primary', 'to-yellow-400', 'from-yellow-400', 'to-red-500', 'from-red-500', 'to-primary', 'bg-gradient-to-r');
      this.progressBar.classList.add('bg-gradient-to-r');
      if (spotsRemaining >= 75) {
        this.progressBar.classList.add('from-secondary', 'via-10%', 'via-secondary', 'to-primary');
      } else if (spotsRemaining > 15) {
        this.progressBar.classList.add('from-red-400', 'via-yellow-400', 'to-yellow-400');
      } else {
        this.progressBar.classList.add('from-red-400', 'via-red-600', 'to-red-600');
      }
      this.progressBar.classList.toggle('animate-pulse-bar', spotsRemaining <= 10);
      if (spotsRemaining > 10) this.progressBar.classList.remove('animate-pulse-bar');
    }
    if (this.spotsMessage) {
      if (spotsRemaining <= 10 && spotsRemaining > 0) {
        this.spotsMessage.textContent = `Only ${spotsRemaining} ${spotWord} left!`;
        this.spotsMessage.className = 'text-red-600 font-bold mt-2';
      } else if (spotsRemaining === 0) {
        this.spotsMessage.textContent = 'All early access spots are filled. Join the waitlist for a chance!';
        this.spotsMessage.className = 'text-red-600 font-bold mt-2';
      } else {
        this.spotsMessage.textContent = '';
      }
    }
    if (this.fomoDiv) {
      if (spotsRemaining <= 10 && spotsRemaining > 0) {
        this.fomoDiv.textContent = `Hurry! Only ${spotsRemaining} ${spotWord} left. Don’t miss out!`;
      } else if (spotsRemaining === 0) {
        this.fomoDiv.textContent = 'All early access spots are filled. You can still join the waitlist for a chance.';
      } else {
        this.fomoDiv.textContent = '';
      }
    }
    if (this.heroJoined) {
      this.heroJoined.textContent = joinedToday;
    }
  }

  showLoadingState() {
    const submitButton = this.form.querySelector('button[type="submit"]');
    if (submitButton) {
      submitButton.disabled = true;
      submitButton.innerHTML = '<span class="inline-block animate-spin mr-2">⏳</span> Processing...';
      submitButton.classList.add('opacity-75', 'cursor-not-allowed');
    }
  }

  hideLoadingState() {
    const submitButton = this.form.querySelector('button[type="submit"]');
    if (submitButton) {
      submitButton.disabled = false;
      submitButton.innerHTML = '🚀 Claim My Spot';
      submitButton.classList.remove('opacity-75', 'cursor-not-allowed');
    }
  }

  async submitForm(event) {
    event.preventDefault();
    this.errorDiv.textContent = '';
    this.successDiv.innerHTML = '';
    // Validate all fields
    const fields = this.form.querySelectorAll('input, select');
    let isValid = true;
    fields.forEach(field => {
      if (!this.validateField(field)) isValid = false;
    });
    if (!isValid) return;
    this.showLoadingState();
    try {
      // Prepare payload (customize as needed)
      const formData = new FormData(this.form);
      const core = {
        name: formData.get('full_name'),
        email: formData.get('email'),
        phone: formData.get('phone'),
        marketing_consent: true
      };
      const payload = {
        core,
        recaptcha_token: '', // Add recaptcha if needed
      };
      if (!currentIdempotencyKey) {
        currentIdempotencyKey = generateIdempotencyKey();
      }
      const res = await fetch(`/api/landing_pages/${this.slug}/leads`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Idempotency-Key': currentIdempotencyKey
        },
        body: JSON.stringify(payload)
      });
      if (res.status === 422) {
        const data = await res.json();
        if (data.errors) {
          let errorMsg = '';
          if (data.errors.email_ciphertext && data.errors.email_ciphertext.length > 0) {
            errorMsg += data.errors.email_ciphertext.join(' ');
            this.showFieldError(this.form.querySelector('input[name="email"]'), data.errors.email_ciphertext[0]);
          }
          if (data.errors.phone_ciphertext && data.errors.phone_ciphertext.length > 0) {
            if (errorMsg) errorMsg += ' ';
            errorMsg += data.errors.phone_ciphertext.join(' ');
            this.showFieldError(this.form.querySelector('input[name="phone"]'), data.errors.phone_ciphertext[0]);
          }
          if (data.errors.marketing_consent && data.errors.marketing_consent.length > 0) {
            if (errorMsg) errorMsg += ' ';
            errorMsg += data.errors.marketing_consent.join(' ');
          }
          this.errorDiv.textContent = errorMsg || 'Please check your input.';
        } else {
          this.errorDiv.textContent = 'Please check your input.';
        }
        return;
      }
      if (!res.ok) throw new Error('Failed to submit');
      // Update local state
      const now = new Date();
      leads.push({ id: Date.now(), created_at: now.toISOString() });
      spotsRemaining = Math.max(0, spotsRemaining - 1);
      if (isToday(now.toISOString())) joinedToday++;
      let spotSecured = spotsRemaining >= 0;
      currentReferralCode = this.generateReferralCode();
      this.updateSpotsUI();
      this.form.reset();
      this.showSuccess(spotSecured);
      setTimeout(() => {
        const el = document.getElementById('waitlist-success');
        if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }, 100);
    } catch (error) {
      this.errorDiv.textContent = 'Something went wrong. Please try again.';
    } finally {
      this.hideLoadingState();
      currentIdempotencyKey = null;
    }
  }

  generateReferralCode() {
    // 8-char random alphanumeric string
    return Math.random().toString(36).slice(2, 10).toUpperCase();
  }

  showSuccess(spotSecured) {
    // Confetti animation
    this.launchConfetti();
    // Coupon code UI
    let message = '';
    if (spotSecured) {
      message = `<div class="text-2xl font-bold text-primary mb-2">🎉 Your spot is secured!</div>
        <div class="mb-4 text-lg text-quaternary">Welcome to the inner circle. Here’s your <span class='text-red-600 font-bold'>50% off coupon</span> for your first year:</div>
        <div class="flex items-center justify-center gap-2 mb-4">
          <span class="bg-gray-100 text-quaternary px-4 py-2 rounded-xl font-mono text-lg font-bold" id="coupon-code">${COUPON_CODE}</span>
          <button class="bg-primary text-white px-3 py-2 rounded-lg font-semibold hover:bg-primary/90 transition" onclick="window.waitlistCopyCoupon('${COUPON_CODE}', event)">Copy</button>
        </div>
        <div class="text-xs text-gray-500 mb-4">Valid for 1 year. We’ve also sent your coupon to your inbox.</div>`;
    } else {
      message = `<div class="text-2xl font-bold text-red-600 mb-2">Waitlist Only</div>
        <div class="mb-4 text-lg text-quaternary">All early access spots are filled. You’re on the waitlist. We’ll notify you if a spot opens. You still get your <span class='text-red-600 font-bold'>50% off coupon</span>:</div>
        <div class="flex items-center justify-center gap-2 mb-4">
          <span class="bg-gray-100 text-quaternary px-4 py-2 rounded-xl font-mono text-lg font-bold" id="coupon-code">${COUPON_CODE}</span>
          <button class="bg-primary text-white px-3 py-2 rounded-lg font-semibold hover:bg-primary/90 transition" onclick="window.waitlistCopyCoupon('${COUPON_CODE}', event)">Copy</button>
        </div>
        <div class="text-xs text-gray-500 mb-4">Valid for 1 year. We’ve also sent your coupon to your inbox.</div>`;
    }
    // Sharing UI
    const shareUrl = window.location.origin + window.location.pathname + `?ref=${currentReferralCode}`;
    message += `<div class="mt-6 mb-2 text-center text-lg text-primary font-semibold">Increase your chances! Share with friends – for every friend who joins, you move up the list.</div>
      <div class="flex flex-col sm:flex-row gap-3 justify-center items-center mb-4">
        <button class="bg-septenary text-quaternary px-4 py-2 rounded-lg font-semibold hover:bg-primary hover:text-white transition" onclick="window.waitlistShare('${shareUrl}', event)">Share via…</button>
        <button class="bg-gray-100 text-quaternary px-4 py-2 rounded-lg font-semibold hover:bg-primary hover:text-white transition" onclick="window.waitlistCopyLink('${shareUrl}', event)">Copy Invite Link</button>
      </div>
      <div class="text-xs text-gray-500">The more friends you invite, the higher your priority!</div>`;
    this.successDiv.innerHTML = message;
  }

  launchConfetti() {
    // Simple confetti effect (can be replaced with a library)
    const confetti = document.createElement('div');
    confetti.style.position = 'fixed';
    confetti.style.left = 0;
    confetti.style.top = 0;
    confetti.style.width = '100vw';
    confetti.style.height = '100vh';
    confetti.style.pointerEvents = 'none';
    confetti.style.zIndex = 9999;
    confetti.innerHTML = Array.from({length: 80}).map(() => {
      const color = ["#6eaa5e", "#b2d99c", "#e6e2af", "#3e563e", "#a37c27", "#8ec07c"][Math.floor(Math.random()*6)];
      const left = Math.random()*100;
      const delay = Math.random()*2;
      const duration = 2 + Math.random()*2;
      return `<div style='position:absolute;left:${left}vw;top:-5vh;width:10px;height:10px;background:${color};border-radius:50%;opacity:0.8;animation:fall ${duration}s ${delay}s linear forwards;'></div>`;
    }).join('');
    document.body.appendChild(confetti);
    const style = document.createElement('style');
    style.innerHTML = `@keyframes fall { to { transform: translateY(110vh); opacity: 0.2; } }`;
    document.head.appendChild(style);
    setTimeout(() => { confetti.remove(); style.remove(); }, 4000);
  }
}

// Toast function for consistent user feedback
window.waitlistToast = function(message, type = 'info') {
  // Remove any existing toast
  const oldToast = document.getElementById('waitlist-toast');
  if (oldToast) oldToast.remove();
  // Create toast
  const toast = document.createElement('div');
  toast.id = 'waitlist-toast';
  toast.className = `fixed top-6 left-1/2 transform -translate-x-1/2 z-50 px-6 py-3 rounded-xl shadow-lg text-white text-base font-semibold transition-all duration-300 pointer-events-auto ${
    type === 'success' ? 'bg-primary' : type === 'error' ? 'bg-red-600' : 'bg-quaternary'
  }`;
  toast.style.opacity = '0';
  toast.textContent = message;
  document.body.appendChild(toast);
  setTimeout(() => { toast.style.opacity = '1'; }, 10);
  setTimeout(() => {
    toast.style.opacity = '0';
    setTimeout(() => { toast.remove(); }, 300);
  }, 2000);
}

window.waitlistCopyCoupon = function(code, event) {
  if (event) {
    event.preventDefault();
    event.stopPropagation();
  }
  navigator.clipboard.writeText(code);
  window.waitlistToast('Coupon code copied!', 'success');
}

window.waitlistShare = function(shareUrl, event) {
  if (event) {
    event.preventDefault();
    event.stopPropagation();
  }
  const shareData = {
    title: 'Join me for Early Access! Only 100 spots!',
    text: 'I just joined the early access waitlist for this amazing new platform. Use my link to join and we both get priority! ',
    url: shareUrl
  };
  if (navigator.share) {
    navigator.share(shareData);
    window.waitlistToast('Share dialog opened!', 'success');
  } else {
    window.waitlistCopyLink(shareUrl, event);
  }
}
window.waitlistCopyLink = function(shareUrl, event) {
  if (event) {
    event.preventDefault();
    event.stopPropagation();
  }
  navigator.clipboard.writeText(shareUrl);
  window.waitlistToast('Invite link copied! Share it with your friends.', 'success');
}

window.waitlistFocusForm = function() {
  const form = document.getElementById('contact');
  if (form) {
    form.scrollIntoView({ behavior: 'smooth', block: 'center' });
    setTimeout(() => {
      const nameField = document.getElementById('full_name');
      if (nameField) nameField.focus();
    }, 400);
  }
}