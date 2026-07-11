const mongoose = require('mongoose');

const WishlistSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
  },
  service: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Ensure at least one of product/service/event is provided (can enforce in validation)
WishlistSchema.index({ user: 1, product: 1 }, { unique: true, sparse: true });
WishlistSchema.index({ user: 1, service: 1 }, { unique: true, sparse: true });
WishlistSchema.index({ user: 1, event: 1 }, { unique: true, sparse: true });

module.exports = mongoose.model('Wishlist', WishlistSchema);