const router = require('express').Router();
const UserController = require("../controllers/user.controller");
const BookingsRouter = require("./bookings.route.js");

router.post('/registration', UserController.register);
router.post('/login', UserController.login);
router.use('/bookings', BookingsRouter);
router.get('/getuser' , UserController.getUser);

module.exports = router;