<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    // role / is_active are intentionally NOT mass-assignable.
    protected $fillable = ['name', 'username', 'email', 'password'];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    protected static function booted(): void
    {
        static::created(function (User $user) {
            $user->profile()->create(Profile::defaults($user));
        });
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function ensureProfile(): Profile
    {
        return $this->profile ?? $this->profile()->create(Profile::defaults($this));
    }

    public function profile(): HasOne
    {
        return $this->hasOne(Profile::class);
    }

    public function stats(): HasMany
    {
        return $this->hasMany(Stat::class)->orderBy('sort_order')->orderBy('id');
    }

    public function highlights(): HasMany
    {
        return $this->hasMany(Highlight::class)->orderBy('sort_order')->orderBy('id');
    }

    public function experiences(): HasMany
    {
        return $this->hasMany(Experience::class)->orderBy('sort_order')->orderBy('id');
    }

    public function skillCategories(): HasMany
    {
        return $this->hasMany(SkillCategory::class)->orderBy('sort_order')->orderBy('id');
    }

    public function projects(): HasMany
    {
        return $this->hasMany(Project::class)->orderBy('sort_order')->orderBy('id');
    }

    public function researchTopics(): HasMany
    {
        return $this->hasMany(ResearchTopic::class)->orderBy('sort_order')->orderBy('id');
    }
}
