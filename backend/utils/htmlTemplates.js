const getGatewayHtml = () => `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FGW Backend Gateway</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f4f7f6;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
            }
            .card {
                background: white;
                padding: 2rem;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                text-align: center;
                max-width: 400px;
                width: 90%;
            }
            h1 {
                color: #2c3e50;
                margin-bottom: 0.5rem;
                font-size: 1.5rem;
            }
            p {
                color: #7f8c8d;
                margin-bottom: 1.5rem;
            }
            .status-badge {
                display: inline-flex;
                align-items: center;
                background-color: #e8f5e9;
                color: #2e7d32;
                padding: 0.5rem 1rem;
                border-radius: 50px;
                font-weight: 600;
                font-size: 0.875rem;
            }
            .status-dot {
                height: 10px;
                width: 10px;
                background-color: #4caf50;
                border-radius: 50%;
                display: inline-block;
                margin-right: 8px;
                box-shadow: 0 0 0 rgba(76, 175, 80, 0.4);
                animation: pulse 2s infinite;
            }
            @keyframes pulse {
                0% { box-shadow: 0 0 0 0px rgba(76, 175, 80, 0.4); }
                70% { box-shadow: 0 0 0 10px rgba(76, 175, 80, 0); }
                100% { box-shadow: 0 0 0 0px rgba(76, 175, 80, 0); }
            }
            .footer {
                margin-top: 2rem;
                font-size: 0.75rem;
                color: #bdc3c7;
            }
        </style>
    </head>
    <body>
        <div class="card">
            <h1>Faarfannaa Galata Waaqayyoo</h1>
            <p>API Gateway & Backend Services</p>
            <div class="status-badge">
                <span class="status-dot"></span>
                System Operational
            </div>
            <div class="footer">
                &copy; ${new Date().getFullYear()} FGW Team • <a href="/health" style="color: inherit; text-decoration: none;">Health Check</a>
            </div>
        </div>
    </body>
    </html>
`;

module.exports = { getGatewayHtml };
