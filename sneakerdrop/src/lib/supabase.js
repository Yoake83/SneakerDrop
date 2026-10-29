import { createClient } from '@supabase/supabase-js';
const url = import.meta.env.VITE_SUPABASE_URL;
const key = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;
export const configured = Boolean(url && key && !url.includes('your-project'));
export const supabase = configured ? createClient(url, key) : null;
export async function getProducts() {
  if (!supabase) return [];
  const { data, error } = await supabase.from('sneakerdrop_products').select('*').order('created_at', { ascending: false });
  if (error) throw error;
  return data;
}
export async function joinWaitlist(productId, email) {
  if (!supabase) throw new Error('The waitlist is not open yet. Please check back soon.');
  const { data, error } = await supabase.rpc('sneakerdrop_join_waitlist', { product_id_input: productId, email_input: email });
  if (error) throw new Error('We couldn’t save your place. Please try again shortly.');
  return data;
}
