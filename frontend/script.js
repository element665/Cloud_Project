const cards = document.querySelectorAll('.card');
const apiUrl = '/api/visit'; // This path will be routed by CloudFront

const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
});

cards.forEach(card => {
    observer.observe(card);
});

document.addEventListener('DOMContentLoaded', () => {
    const counterElement = document.getElementById('counter');

    fetch(apiUrl)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            if (data.visitor_count !== undefined) {
                counterElement.textContent = data.visitor_count;
            } else {
                throw new Error('Visitor count not found in response');
            }
        })
        .catch(error => {
            console.error('Could not fetch visitor count:', error);
            counterElement.textContent = 'Error';
        });
});
