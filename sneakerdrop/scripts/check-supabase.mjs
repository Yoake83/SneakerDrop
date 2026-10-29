// Read-only connection checks. Run with: node --env-file=.env scripts/check-supabase.mjs
const url = process.env.VITE_SUPABASE_URL;
const key = process.env.VITE_SUPABASE_PUBLISHABLE_KEY;
if (!url || !key || url.includes('your-project')) {
  console.error('Add your project URL and publishable key to .env first.');
  process.exit(1);
}
if (key.startsWith('sb_secret_')) {
  console.error('Use a publishable key, never a secret key, for this app.');
  process.exit(1);
}
const headers = { apikey: key };
// Legacy anon JWTs also work as bearer tokens; modern publishable keys do not.
if (key.startsWith('eyJ')) {
  const payload = JSON.parse(Buffer.from(key.split('.')[1], 'base64url').toString());
  if (payload.role !== 'anon') {
    console.error('The legacy key must have the anon role.');
    process.exit(1);
  }
  headers.Authorization = `Bearer ${key}`;
}
try {
  const products = await fetch(`${url}/rest/v1/sneakerdrop_products?select=id,name,availability&limit=100`, { headers });
  if (!products.ok) throw new Error('Product reads failed. Check the project URL, key, schema, and public SELECT policy.');
  const rows = await products.json();
  console.log(`Connected: ${rows.length} products are publicly readable.`);
  if (rows.length < 3) throw new Error('Run supabase/seed.sql to provide at least three sneakers.');
  for (const table of ['sneakerdrop_waitlist', 'sneakerdrop_admin_users']) {
    const response = await fetch(`${url}/rest/v1/${table}?select=*&limit=1`, { headers });
    if (![401, 403].includes(response.status)) throw new Error(`${table} is not locked down as expected. Apply supabase/schema.sql before publishing.`);
    console.log(`Protected: anonymous access to ${table} is denied.`);
  }
  console.log('Read-only connection checks passed. Admin and waitlist write acceptance tests still need to be completed.');
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
