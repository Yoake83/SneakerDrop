export function normalizeEmail(value) { return value.trim().toLowerCase(); }
export function validEmail(value) { return value.length <= 254 && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value); }
export function validImageUrl(value) { try { return new URL(value).protocol === 'https:'; } catch { return false; } }
export function validateProduct(product) {
  if (!product.name?.trim() || product.name.length > 100) return 'Use a name between 1 and 100 characters.';
  if (!product.description?.trim() || product.description.length > 2000) return 'Add a description up to 2,000 characters.';
  if (!validImageUrl(product.image_url)) return 'Use a valid HTTPS image URL.';
  if (!Number.isFinite(Number(product.price)) || Number(product.price) <= 0 || Number(product.price) > 100000) return 'Enter a price between 0.01 and 100,000.';
  if (!['available', 'coming_soon', 'sold_out'].includes(product.availability)) return 'Choose a valid availability.';
  return null;
}
