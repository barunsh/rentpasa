const mongoose = require('mongoose');

const { Schema } = mongoose;

const bookSchema = new mongoose.Schema({
  propertyAddress: { type: String, required: true },
  userId: {type: String},
  userName: {type: String},
  propertyLocality: { type: String, required: true },
  propertyRent: { type: Number, required: true },
  propertyType: { type: String, required: true },
  propertyBalconyCount: { type: Number, required: true },
  propertyBedroomCount: { type: Number, required: true },
  propertyDate: { type: Date, required: true },
  bookingRemaining: { type: Number },
});

module.exports = mongoose.model('Book', bookSchema);