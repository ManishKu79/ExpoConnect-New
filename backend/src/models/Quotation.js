const mongoose = require('mongoose');

const QuotationSchema = new mongoose.Schema({
  company: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Company',
    required: true,
  },
  client: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  items: [{
    description: String,
    quantity: Number,
    unitPrice: Number,
    total: Number,
  }],
  totalAmount: {
    type: Number,
    required: true,
  },
  currency: {
    type: String,
    default: 'USD',
  },
  status: {
    type: String,
    enum: ['draft', 'sent', 'accepted', 'rejected', 'expired'],
    default: 'draft',
  },
  validUntil: Date,
  notes: String,
  attachments: [String],
  createdAt: {
    type: Date,
    default: Date.now,
  },
}, {
  timestamps: true,
});

QuotationSchema.index({ company: 1, client: 1 });
QuotationSchema.index({ status: 1 });

module.exports = mongoose.model('Quotation', QuotationSchema);