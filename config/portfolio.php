<?php

return [
    // Username whose portfolio is shown at "/". Leave empty to show the public directory instead.
    'default_user' => env('PORTFOLIO_DEFAULT_USER'),

    // Allow visitors to create their own portfolio account at /register
    'allow_registration' => (bool) env('PORTFOLIO_ALLOW_REGISTRATION', true),

    // Used by the database seeder only
    'admin_name' => env('PORTFOLIO_ADMIN_NAME', 'Administrator'),
    'admin_email' => env('PORTFOLIO_ADMIN_EMAIL', 'admin@example.com'),
    'admin_password' => env('PORTFOLIO_ADMIN_PASSWORD', 'ChangeMe123!'),
];
