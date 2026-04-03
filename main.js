import './style.css';

document.addEventListener('DOMContentLoaded', () => {

   // 1. Mobile navigation toggle
   const menuToggle = document.getElementById('menu-toggle');
   const navLinks = document.getElementById('nav-links');
   
   menuToggle.addEventListener('click', () => {
      navLinks.classList.toggle('active');
      if (navLinks.classList.contains('active')) {
         menuToggle.innerHTML = '✕';
      } else {
         menuToggle.innerHTML = '≡';
      }
   });

   // Close nav when clicking a link (mobile)
   const navAnchors = document.querySelectorAll('.nav-links a');
   navAnchors.forEach(a => {
      a.addEventListener('click', () => {
         navLinks.classList.remove('active');
         menuToggle.innerHTML = '≡';
      });
   });

   // 2. Continuous Parallax for Hero
   const heroBg = document.querySelector('.js-parallax');
   window.addEventListener('scroll', () => {
      const scrollY = window.scrollY;
      // 40% rate as per Rolex guide
      if (scrollY < window.innerHeight) {
         heroBg.style.transform = `translateY(${scrollY * 0.4}px)`;
      }
   });

   // 3. Section divider animation
   const dividers = document.querySelectorAll('.js-divider');
   
   const dividerObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
         if (entry.isIntersecting) {
            entry.target.classList.add('animate');
            dividerObserver.unobserve(entry.target);
         }
      });
   }, { threshold: 0.1 });

   dividers.forEach(div => dividerObserver.observe(div));

   // 4. Slide-in Product Panel
   const openBtns = document.querySelectorAll('.js-open-product');
   const productPanel = document.getElementById('product-panel');
   const closeBtn = document.getElementById('close-panel');
   const menuOverlay = document.getElementById('menu-overlay');

   openBtns.forEach(btn => {
      btn.addEventListener('click', (e) => {
         e.preventDefault();
         productPanel.classList.add('active');
         menuOverlay.classList.add('active');
      });
   });

   // Also bind the caseback image to pop open panel
   const movementImg = document.getElementById('movement-img');
   movementImg.addEventListener('click', () => {
      productPanel.classList.add('active');
      menuOverlay.classList.add('active');
   });

   const closePanelFn = () => {
      productPanel.classList.remove('active');
      menuOverlay.classList.remove('active');
   }

   closeBtn.addEventListener('click', closePanelFn);
   menuOverlay.addEventListener('click', () => {
      closePanelFn();
      // also close mobile menu if it was open
      if(navLinks.classList.contains('active')) {
         navLinks.classList.remove('active');
         menuToggle.innerHTML = '≡';
      }
   });

});
