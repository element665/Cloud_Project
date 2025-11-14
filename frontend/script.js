document.addEventListener('DOMContentLoaded', () => {
    const apiUrl = '/api/visit'; // This path will be routed by CloudFront
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
            console.error('Error fetching visitor count:', error);
            counterElement.textContent = 'N/A';
        });
});
