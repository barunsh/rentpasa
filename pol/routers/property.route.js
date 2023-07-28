const router = require('express').Router();
const PropertyController = require('../controllers/property.controller.js');
const BookController = require('../controllers/book.controller.js');
const fileUploadMiddleware = require('../middleware/multer.js');
const { uploadImage } = require('../services/property.services.js');

router.post('/properties', fileUploadMiddleware, PropertyController.createProperty);
router.get('/getproperty' , PropertyController.getProperty);
router.post('/uploadImage', fileUploadMiddleware, PropertyController.uploadImage);
module.exports = router;