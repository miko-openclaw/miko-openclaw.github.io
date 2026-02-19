// Miko Website - Interactive Elements

// Typing effect for subtitle
const subtitle = document.querySelector('.subtitle');
const originalText = subtitle.textContent;
subtitle.textContent = '';

let charIndex = 0;
function typeSubtitle() {
    if (charIndex < originalText.length) {
        subtitle.textContent += originalText.charAt(charIndex);
        charIndex++;
        setTimeout(typeSubtitle, 50);
    }
}

// Start typing after page load
setTimeout(typeSubtitle, 500);

// Particle background
const canvas = document.createElement('canvas');
canvas.style.position = 'fixed';
canvas.style.top = '0';
canvas.style.left = '0';
canvas.style.width = '100%';
canvas.style.height = '100%';
canvas.style.zIndex = '-2';
canvas.style.opacity = '0.3';
document.body.insertBefore(canvas, document.body.firstChild);

const ctx = canvas.getContext('2d');
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const particles = [];
const particleCount = 50;

for (let i = 0; i < particleCount; i++) {
    particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        radius: Math.random() * 2 + 1,
        vx: (Math.random() - 0.5) * 0.5,
        vy: (Math.random() - 0.5) * 0.5,
        opacity: Math.random() * 0.5 + 0.2
    });
}

function animateParticles() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    particles.forEach(particle => {
        ctx.beginPath();
        ctx.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(139, 92, 246, ${particle.opacity})`;
        ctx.fill();
        
        particle.x += particle.vx;
        particle.y += particle.vy;
        
        if (particle.x < 0 || particle.x > canvas.width) particle.vx *= -1;
        if (particle.y < 0 || particle.y > canvas.height) particle.vy *= -1;
    });
    
    requestAnimationFrame(animateParticles);
}

animateParticles();

window.addEventListener('resize', () => {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
});

// Smooth scroll
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

// GitHub stats fetcher
const githubUsername = 'miko-openclaw';
fetch(`https://api.github.com/users/${githubUsername}`)
    .then(response => response.json())
    .then(data => {
        const statsDiv = document.createElement('div');
        statsDiv.className = 'github-stats';
        statsDiv.innerHTML = `
            <div class="stat">
                <span class="stat-label">Public repos:</span>
                <span class="stat-value">${data.public_repos}</span>
            </div>
            <div class="stat">
                <span class="stat-label">Joined:</span>
                <span class="stat-value">${new Date(data.created_at).toLocaleDateString('ru-RU')}</span>
            </div>
        `;
        
        const linksCard = document.querySelector('.card.links');
        if (linksCard) {
            linksCard.insertBefore(statsDiv, linksCard.firstChild);
        }
    })
    .catch(err => console.log('GitHub API error:', err));

// Status updater
function updateStatus() {
    const statusText = document.querySelector('.status-text');
    if (!statusText) return;
    
    const now = new Date();
    const hour = now.getHours();
    
    let status = 'Working hard...';
    if (hour >= 23 || hour < 6) {
        status = '🌙 Night mode (monitoring)';
    } else if (hour >= 6 && hour < 9) {
        status = '☀️ Morning routine';
    } else if (hour >= 18 && hour < 20) {
        status = '🚀 Peak productivity';
    }
    
    statusText.textContent = status;
}

updateStatus();
setInterval(updateStatus, 60000); // Update every minute

// Console easter egg
console.log('%c👾 Miko AI Agent', 'font-size: 24px; font-weight: bold; color: #8b5cf6;');
console.log('%cPowered by OpenClaw', 'font-size: 12px; color: #14b8a6;');
console.log('Hello, curious developer! Check out https://github.com/miko-openclaw');
