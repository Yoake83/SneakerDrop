# Sneaker motion asset

Created with the built-in image-generation tool. Final asset: `public/images/motion-sneaker.png`. Generated alpha transparency is preserved. This is an editorial concept asset, separate from database products.

## Final prompt

Use case: product-mockup. Asset type: transparent cutout sneaker for the SneakerDrop website's interactive motion showcase. Generate ONE photorealistic premium original unbranded low-top running/lifestyle sneaker, full shoe visible, side three-quarter view, toe points left and slightly toward viewer, heel at right. Chunky sculpted chalk-white sole, warm stone suede panels, slate mesh, muted forest green details and cream laces. Modern refined independent footwear design. Crisp textile texture, soft studio product lighting. Isolated on a truly transparent background with no floor, no cast shadow, no backdrop, no graphic decorations. Wide horizontal composition, shoe occupies 85% of frame with margin all sides. No text, no letters, no logos, no trademarks, no people. This is a marketing concept shoe, not a database product.

## Motion implementation

CSS transforms animate a transparent 2D image. This is not a 360-degree model. The image floats and gently rotates, responds to desktop pointer position, and supports angle buttons and a keyboard/touch range slider. Visitors can pause animation. Automatic motion is disabled for reduced-motion preferences and paused when offscreen or when the browser tab is hidden.
