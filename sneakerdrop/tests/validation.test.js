import test from 'node:test';
import assert from 'node:assert/strict';
import { validEmail, normalizeEmail, validateProduct, validImageUrl } from '../src/lib/validation.js';
test('normalizes email consistently for duplicate protection', () => { assert.equal(normalizeEmail('  Person+drop@EXAMPLE.com '), 'person+drop@example.com'); });
test('rejects malformed emails and accepts plus addressing', () => { for (const email of ['hello','a@@b.com','a b@c.com','@a.com','a@b','a@b.com\n','x'.repeat(255)+'@a.com']) assert.equal(validEmail(email), false, email); assert.equal(validEmail('person+drop@example.com'), true); });
test('image URLs must use HTTPS', () => { for (const url of ['javascript:alert(1)','http://example.com/a.jpg','data:image/png;base64,abc','invalid']) assert.equal(validImageUrl(url), false); assert.equal(validImageUrl('https://images.unsplash.com/photo-1'), true); });
test('rejects invalid prices and statuses', () => { const p = { name:'Velocity',description:'A sneaker',image_url:'https://example.com/shoe.jpg',price:100,availability:'available' }; assert.equal(validateProduct(p), null); for (const price of [-1,0,'abc',Infinity,100001]) assert.ok(validateProduct({...p,price})); assert.ok(validateProduct({...p,availability:'admin'})); });
