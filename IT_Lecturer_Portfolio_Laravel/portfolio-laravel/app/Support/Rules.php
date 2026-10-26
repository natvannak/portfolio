<?php

namespace App\Support;

use Illuminate\Validation\Rule;

class Rules
{
    public const RESERVED = [
        'admin', 'login', 'logout', 'register', 'storage', 'css', 'js', 'images',
        'up', 'api', 'account', 'password', 'dashboard', 'index', 'public', 'vendor',
    ];

    public static function username(?int $ignoreId = null): array
    {
        return [
            'required', 'string', 'min:3', 'max:30',
            'regex:/^[a-z0-9_-]+$/',
            Rule::notIn(self::RESERVED),
            Rule::unique('users', 'username')->ignore($ignoreId),
        ];
    }
}
