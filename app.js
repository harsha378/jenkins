const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const version = process.env.VERSION || 'v1.0';

app.get('/', (req, res) => {
    res.json({
        message: 'Hi Harsha',
        version: version,
        environment: process.env.NODE_ENV || 'development',
        timestamp: new Date().toISOString()
    });
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy', version: version });
});

app.listen(port, () => {
    console.log(`App running on port ${port}, version ${version}`);
});
