function fetchHtml(item) {
    return fetch('sample.html')
        .then(response => response.text())
        .catch(() => null);
}