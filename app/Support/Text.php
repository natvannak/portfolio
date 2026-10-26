<?php

namespace App\Support;

use Illuminate\Support\HtmlString;

class Text
{
    /** Non-empty trimmed lines. */
    public static function lines(?string $s): array
    {
        $parts = preg_split('/\R/', (string) $s) ?: [];

        return array_values(array_filter(array_map('trim', $parts), fn ($l) => $l !== ''));
    }

    /** Comma separated values. */
    public static function csv(?string $s): array
    {
        return array_values(array_filter(array_map('trim', explode(',', (string) $s)), fn ($l) => $l !== ''));
    }

    /** Escapes the text, then turns **bold** into <strong>. Safe for output. */
    public static function inline(?string $s): HtmlString
    {
        return new HtmlString(preg_replace('/\*\*(.+?)\*\*/s', '<strong>$1</strong>', e((string) $s)));
    }
}
