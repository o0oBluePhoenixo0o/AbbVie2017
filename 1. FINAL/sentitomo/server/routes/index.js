var express = require('express');
const path = require('path');
var router = express.Router();

// The "catchall" handler: for any request that doesn't
// match one above, send back React's index.html file.
router.get('/', (req, res) => {
    res.send('Server is running.. oh well ;)');
});

module.exports = router;
