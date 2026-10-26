<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Profile extends Model
{
    protected $guarded = ['id', 'user_id'];

    protected function casts(): array
    {
        return ['is_public' => 'boolean'];
    }

    public static function defaults(User $user): array
    {
        return [
            'is_public' => false,
            'full_name' => $user->name,
            'headline' => 'PORTFOLIO',
            'hero_line1' => 'Hello, I am ' . $user->name . '.',
            'hero_line2' => 'Welcome to my portfolio.',
            'about_title' => 'About me.',
            'experience_title' => 'Experience.',
            'skills_title' => 'Skills.',
            'projects_title' => 'Projects.',
            'research_title' => 'Research & learning.',
            'contact_title' => 'Get in touch.',
        ];
    }

    public function initials(): string
    {
        $words = preg_split('/\s+/', trim($this->full_name ?: '?')) ?: ['?'];
        $letters = array_map(fn ($w) => mb_strtoupper(mb_substr($w, 0, 1)), $words);

        return implode('', array_slice($letters, 0, 2));
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
