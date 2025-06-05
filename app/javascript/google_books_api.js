export default class GoogleBooksAPI {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  }

  /* query formatting:
   * - Book Title, Author Name
   * - Book Title
   */
  async searchBooks(query) {
    let parts = query.split(',');
    if (parts.length > 1) {
      // If there are multiple parts, assume the first part is the title and the second part is the author
      query = `${parts[0].trim()}+inauthor:${parts[1].trim()}`;
    } else {
      // Otherwise, just use the query as is
      query = parts[0].trim();
    }
    const url = `${this.baseUrl}?q=${encodeURIComponent(query)}`;
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json().then(data => {
      console.log(data);
      if (data.items) {
        return data.items.map(item => ({
          authors: item.volumeInfo.authors || [],
          title: item.volumeInfo.title.split(':')[0].trim(),
          thumbnail: item.volumeInfo.imageLinks ? item.volumeInfo.imageLinks.thumbnail : null,
          id: item.id,
        }));
      } else {
        return [];
      }
    });
  }

  async getBookDetails(volumeId) {
    const url = `${this.baseUrl}/${volumeId}?key=${this.apiKey}`;
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json();
  }
}