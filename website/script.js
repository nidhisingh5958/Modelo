// API Base URL
const API_BASE_URL = 'http://localhost:8000';

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
            
            // Close mobile menu if open
            const navMenu = document.querySelector('.nav-menu');
            const navToggle = document.querySelector('.nav-toggle');
            if (navMenu.classList.contains('active')) {
                navMenu.classList.remove('active');
                navToggle.classList.remove('active');
            }
        }
    });
});

// Mobile navigation toggle
document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.querySelector('.nav-menu');
    
    if (navToggle) {
        navToggle.addEventListener('click', () => {
            navMenu.classList.toggle('active');
            navToggle.classList.toggle('active');
        });
    }
    
    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!navToggle.contains(e.target) && !navMenu.contains(e.target)) {
            navMenu.classList.remove('active');
            navToggle.classList.remove('active');
        }
    });
});

// Navbar scroll effect
window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 100) {
        navbar.style.background = 'rgba(255, 255, 255, 0.98)';
        navbar.style.boxShadow = '0 2px 20px rgba(0,0,0,0.1)';
    } else {
        navbar.style.background = 'rgba(255, 255, 255, 0.95)';
        navbar.style.boxShadow = 'none';
    }
});

// Demo tabs functionality
document.addEventListener('DOMContentLoaded', function() {
    const demoTabs = document.querySelectorAll('.demo-tab');
    const demoPanels = document.querySelectorAll('.demo-panel');
    
    demoTabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // Remove active class from all tabs and panels
            demoTabs.forEach(t => t.classList.remove('active'));
            demoPanels.forEach(p => p.classList.remove('active'));
            
            // Add active class to clicked tab
            tab.classList.add('active');
            
            // Show corresponding panel
            const targetPanel = document.getElementById(tab.dataset.tab);
            if (targetPanel) {
                targetPanel.classList.add('active');
            }
        });
    });
});

// Intersection Observer for animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe elements for animation
document.addEventListener('DOMContentLoaded', function() {
    const animateElements = document.querySelectorAll('.feature-card, .ai-feature, .demo-container');
    
    animateElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
});

// Counter animation for stats
function animateCounter(element, target, duration = 2000) {
    let start = 0;
    const increment = target / (duration / 16);
    
    const timer = setInterval(() => {
        start += increment;
        if (start >= target) {
            element.textContent = target + '%';
            clearInterval(timer);
        } else {
            element.textContent = Math.floor(start) + '%';
        }
    }, 16);
}

// Trigger counter animation when stats come into view
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const statNumbers = entry.target.querySelectorAll('.stat-number');
            statNumbers.forEach(stat => {
                const target = parseInt(stat.textContent);
                animateCounter(stat, target);
            });
            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

document.addEventListener('DOMContentLoaded', function() {
    const heroStats = document.querySelector('.hero-stats');
    if (heroStats) {
        statsObserver.observe(heroStats);
    }
});

// Animate metric bars in demo section
const metricsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const metricFills = entry.target.querySelectorAll('.metric-fill');
            metricFills.forEach((fill, index) => {
                setTimeout(() => {
                    fill.style.width = fill.style.width || '0%';
                }, index * 200);
            });
            metricsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

document.addEventListener('DOMContentLoaded', function() {
    const analysisMetrics = document.querySelector('.analysis-metrics');
    if (analysisMetrics) {
        metricsObserver.observe(analysisMetrics);
    }
});

// Mobile menu toggle (for future mobile optimization)
function toggleMobileMenu() {
    const navMenu = document.querySelector('.nav-menu');
    navMenu.classList.toggle('active');
}

// Add click handlers for download buttons
document.addEventListener('DOMContentLoaded', function() {
    const downloadButtons = document.querySelectorAll('.download-btn, .btn');
    
    downloadButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            // Add ripple effect
            const ripple = document.createElement('span');
            const rect = this.getBoundingClientRect();
            const size = Math.max(rect.width, rect.height);
            const x = e.clientX - rect.left - size / 2;
            const y = e.clientY - rect.top - size / 2;
            
            ripple.style.width = ripple.style.height = size + 'px';
            ripple.style.left = x + 'px';
            ripple.style.top = y + 'px';
            ripple.classList.add('ripple');
            
            this.appendChild(ripple);
            
            setTimeout(() => {
                ripple.remove();
            }, 600);
        });
    });
});

// Add CSS for ripple effect
const style = document.createElement('style');
style.textContent = `
    .btn, .download-btn {
        position: relative;
        overflow: hidden;
    }
    
    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: scale(0);
        animation: ripple-animation 0.6s linear;
        pointer-events: none;
    }
    
    @keyframes ripple-animation {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Parallax effect for hero section
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const hero = document.querySelector('.hero');
    const rate = scrolled * -0.5;
    
    if (hero) {
        hero.style.transform = `translateY(${rate}px)`;
    }
});

// API Integration Functions
async function testColorCompatibility() {
    const color1 = document.getElementById('color1').value;
    const color2 = document.getElementById('color2').value;
    const resultDiv = document.getElementById('api-result');
    
    showLoading();
    
    try {
        const response = await fetch(`${API_BASE_URL}/api/analysis/color-compatibility`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ color1, color2 })
        });
        
        if (response.ok) {
            const data = await response.json();
            resultDiv.innerHTML = `
                <div class="api-result">
                    <h4>Color Compatibility Result</h4>
                    <p><strong>Colors:</strong> ${data.color1} + ${data.color2}</p>
                    <p><strong>Compatibility Score:</strong> ${(data.compatibility_score * 100).toFixed(1)}%</p>
                    <p><strong>Compatible:</strong> ${data.compatible ? '✅ Yes' : '❌ No'}</p>
                </div>
            `;
        } else {
            throw new Error('API request failed');
        }
    } catch (error) {
        resultDiv.innerHTML = `
            <div class="api-result" style="border-color: #ef4444; background: rgba(239, 68, 68, 0.1); color: #ef4444;">
                <h4>Connection Error</h4>
                <p>Unable to connect to Modelo API. Make sure the backend server is running on localhost:8000</p>
                <p><small>Error: ${error.message}</small></p>
            </div>
        `;
    } finally {
        hideLoading();
    }
}

// Generate Outfits Demo
function generateOutfits() {
    const occasion = document.querySelector('.occasion-select').value;
    const weather = document.querySelector('.weather-select').value;
    
    showLoading();
    
    // Simulate API call with demo data
    setTimeout(() => {
        const outfitSuggestions = document.querySelector('.outfit-suggestions');
        const demoOutfits = {
            work: [
                { items: ['Navy Blazer', 'White Shirt', 'Black Trousers'], score: 95 },
                { items: ['Gray Suit', 'Blue Shirt', 'Black Shoes'], score: 92 }
            ],
            casual: [
                { items: ['Denim Jacket', 'White Tee', 'Blue Jeans'], score: 88 },
                { items: ['Cardigan', 'Striped Shirt', 'Khaki Pants'], score: 85 }
            ],
            formal: [
                { items: ['Black Suit', 'White Shirt', 'Black Tie'], score: 98 },
                { items: ['Navy Dress', 'Pearl Necklace', 'Heels'], score: 94 }
            ],
            party: [
                { items: ['Sequin Top', 'Black Skirt', 'Heels'], score: 91 },
                { items: ['Silk Dress', 'Statement Earrings', 'Clutch'], score: 89 }
            ]
        };
        
        const outfits = demoOutfits[occasion] || demoOutfits.casual;
        
        outfitSuggestions.innerHTML = outfits.map(outfit => `
            <div class="suggestion-card">
                <div class="suggestion-header">
                    <span class="occasion-tag">${occasion.charAt(0).toUpperCase() + occasion.slice(1)}</span>
                    <span class="ai-score">${outfit.score}% Match</span>
                </div>
                <div class="suggestion-items">
                    ${outfit.items.map(item => `<div class="suggestion-item">${item}</div>`).join('')}
                </div>
                <div class="suggestion-actions">
                    <button class="btn-save" onclick="saveOutfit(this)">💾 Save</button>
                    <button class="btn-rate" onclick="rateOutfit(this)">⭐ Rate</button>
                </div>
            </div>
        `).join('');
        
        hideLoading();
    }, 1000);
}

// Save Outfit Demo
function saveOutfit(button) {
    button.innerHTML = '✅ Saved';
    button.style.background = '#22c55e';
    button.style.color = 'white';
    setTimeout(() => {
        button.innerHTML = '💾 Save';
        button.style.background = '';
        button.style.color = '';
    }, 2000);
}

// Rate Outfit Demo
function rateOutfit(button) {
    const rating = Math.floor(Math.random() * 2) + 4; // 4 or 5 stars
    button.innerHTML = `⭐ ${rating}/5`;
    button.style.background = '#fbbf24';
    button.style.color = 'white';
    setTimeout(() => {
        button.innerHTML = '⭐ Rate';
        button.style.background = '';
        button.style.color = '';
    }, 2000);
}

// Newsletter Subscription
function subscribeNewsletter(event) {
    event.preventDefault();
    const email = event.target.querySelector('input[type="email"]').value;
    const button = event.target.querySelector('button');
    
    button.innerHTML = 'Subscribing...';
    button.disabled = true;
    
    setTimeout(() => {
        button.innerHTML = '✅ Subscribed!';
        button.style.background = '#22c55e';
        event.target.querySelector('input').value = '';
        
        setTimeout(() => {
            button.innerHTML = 'Subscribe';
            button.style.background = '';
            button.disabled = false;
        }, 3000);
    }, 1000);
}

// Code Tab Switching
document.addEventListener('DOMContentLoaded', function() {
    const codeTabs = document.querySelectorAll('.code-tab');
    const codeBlocks = document.querySelectorAll('.code-block');
    
    codeTabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // Remove active class from all tabs and blocks
            codeTabs.forEach(t => t.classList.remove('active'));
            codeBlocks.forEach(b => b.classList.remove('active'));
            
            // Add active class to clicked tab
            tab.classList.add('active');
            
            // Show corresponding code block
            const targetLang = tab.dataset.lang;
            const targetBlock = document.getElementById(targetLang);
            if (targetBlock) {
                targetBlock.classList.add('active');
            }
        });
    });
});

// Loading Functions
function showLoading() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
        overlay.classList.add('show');
    }
}

function hideLoading() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
        overlay.classList.remove('show');
    }
}

// Page Load Animation
window.addEventListener('load', () => {
    hideLoading();
    document.body.style.opacity = '1';
});

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    // Hide loading overlay after a short delay
    setTimeout(() => {
        hideLoading();
    }, 500);
    
    // Add smooth reveal animation to elements
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Observe elements for animation
    const animateElements = document.querySelectorAll('.feature-card, .ai-feature, .api-feature');
    animateElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
});

// Service Worker Registration
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then(registration => {
                console.log('SW registered: ', registration);
            })
            .catch(registrationError => {
                console.log('SW registration failed: ', registrationError);
            });
    });
}